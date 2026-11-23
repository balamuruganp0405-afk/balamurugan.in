# Native PowerShell Web Server for Unified Local CMS
$rootDir = $PSScriptRoot
if (-not $rootDir) { $rootDir = (Get-Location).Path }
$port = 3000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")

try {
    $listener.Start()
    Write-Output "=== Balamurugan P. Local CMS Server Started ==="
    Write-Output "Open http://localhost:$port/bala-admin.html in your browser to manage your blog."
    Write-Output "Press Ctrl+C in this terminal window to stop the server."
} catch {
    Write-Error "Failed to start listener on port $port. Make sure the port is not in use."
    exit
}

$adminEmail = "balamuruganp0405@gmail.com"
$adminPassword = "Bala@6374191927"
$secureToken = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$adminEmail:$adminPassword:bala_cms_salt"))

# Template HTML for generating new blog posts
$blogTemplate = @'
<!DOCTYPE html>
<html lang="en" data-theme="dark">
<head>
  <!-- Google Tag Manager -->
  <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
  new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
  j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
  'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
  })(window,document,'script','dataLayer','GTM-NCZX7WP6');</script>
  <!-- End Google Tag Manager -->
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{TITLE}}</title>
  <meta name="description" content="{{DESCRIPTION}}">
  
  <!-- CSS Stylesheet -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Outfit:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="style.css">
  <link rel="icon" type="image/png" href="logo.png">
</head>
<body>
  <!-- Google Tag Manager (noscript) -->
  <noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-NCZX7WP6"
  height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
  <!-- End Google Tag Manager (noscript) -->

  <!-- Preloader -->
  <div class="loader-overlay">
    <div class="loader-spinner" aria-label="Loading page"></div>
  </div>

  <!-- Top Bar -->
  <div class="top-bar">
    <div class="container" style="display: flex; justify-content: center; align-items: center; height: 100%;">
      <a href="tel:+916374191927" class="top-bar-link">
        <svg viewBox="0 0 24 24"><path d="M20 15.5c-1.25 0-2.45-.2-3.57-.57-.35-.11-.74-.03-1.02.24l-2.2 2.2c-2.83-1.44-5.15-3.75-6.59-6.59l2.2-2.2c.28-.28.36-.67.25-1.02C8.7 6.45 8.5 5.25 8.5 4c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1 0 9.39 7.61 17 17 17 .55 0 1-.45 1-1v-3.5c0-.55-.45-1-1-1z"/></svg>
        +91 63741 91927
      </a>
    </div>
  </div>

  <!-- Sticky Navbar -->
  <nav class="navbar" id="navbar">
    <div class="container">
      <a href="index.html" class="logo-text-wrapper">
        <span class="logo-title">Balamurugan P</span>
        <span class="logo-subtitle">Digital Marketer</span>
      </a>
      <ul class="nav-menu">
        <li><a href="index.html" class="nav-link">Home</a></li>
        <li><a href="about.html" class="nav-link">About Us</a></li>
        <li><a href="services.html" class="nav-link">Services</a></li>
        <li><a href="blog.html" class="nav-link active">Blog</a></li>
        <li><a href="contact.html" class="nav-link">Contact Us</a></li>
      </ul>
      <div class="nav-actions">
        <a href="contact.html" class="btn btn-primary nav-btn-desktop">Free Consultation</a>
        <button class="burger" aria-label="Open navigation menu">
          <span></span>
          <span></span>
          <span></span>
        </button>
      </div>
    </div>
  </nav>

  <!-- Main Section -->
  <main class="section" style="padding-top: calc(var(--nav-height) + 40px);">
    <div class="container">
      
      <!-- Breadcrumbs -->
      <nav class="breadcrumb">
        <a href="index.html">Home</a>
        <span class="breadcrumb-sep">/</span>
        <a href="blog.html">Blog</a>
        <span class="breadcrumb-sep">/</span>
        <span>{{BREADCRUMB}}</span>
      </nav>

      <!-- Inner Grid -->
      <div class="blog-inner-container">
        
        <!-- Left Column: Article Body -->
        <article class="article-wrap">
          <header class="article-header">
            <span class="badge"><a href="{{CATEGORY_URL}}" class="inline-link" style="color: inherit; text-decoration: none;">{{CATEGORY_NAME}}</a></span>
            <h1 class="entry-title">{{TITLE}}</h1>
            <div class="article-meta-row">
              <div class="article-meta-item">
                <svg viewBox="0 0 24 24"><path d="M9 11H7v2h2v-2zm4 0h-2v2h2v-2zm4 0h-2v2h2v-2zm2-7h-1V2h-2v2H8V2H6v2H5c-1.11 0-1.99.9-1.99 2L3 19c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 15H5V9h14v10z"/></svg>
                Published: {{DATE}}
              </div>
              <div class="article-meta-item">
                <svg viewBox="0 0 24 24"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zm3.3 14.7L11 12.4V7h1.5v4.6l3.8 2.3-.7 1.1z"/></svg>
                Read Time: {{READTIME}}
              </div>
              <div class="article-meta-item">
                <svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                Author: <a href="index.html" class="inline-link">Balamurugan P</a>
              </div>
            </div>
          </header>

          <div class="article-cover-box">
            <img decoding="async" src="{{IMAGE}}" alt="{{TITLE}} Cover" width="1024" height="576" loading="lazy">
          </div>

          <div class="article-content">
            {{CONTENT}}
          </div>
        </article>

        <!-- Right Column: Sidebar -->
        <aside class="sidebar-wrap">
          
          <!-- Widget 1: Author Bio -->
          <div class="sidebar-widget">
            <div class="sidebar-author">
              <img decoding="async" loading="lazy" src="Balamurugan.P.png" alt="Balamurugan P - Freelance Digital Marketing Specialist and SEO Expert in Chennai" class="sidebar-author-img" width="846" height="1024">
              <h3><a href="index.html" class="inline-link" style="color: inherit; text-decoration: none;">Balamurugan P</a></h3>
              <div class="sidebar-author-role"><a href="about.html" class="inline-link">Digital Marketer</a></div>
              <p>Freelance digital strategist helping companies scale traffic through SEO audits, <a href="google-ads-services.html" class="inline-link">Google Ads</a> budgets, and conversion designs.</p>
              <div class="social-links" style="justify-content:center; gap:0.5rem;">
                <a href="https://linkedin.com" target="_blank" class="social-icon" style="width:32px; height:32px;"><svg viewBox="0 0 24 24" style="width:14px; height:14px;"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.779-1.75-1.75s.784-1.75 1.75-1.75 1.75.779 1.75 1.75-.784 1.75-1.75 1.75zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg></a>
              </div>
            </div>
          </div>

          <!-- Widget 2: Related Articles -->
          <div class="sidebar-widget">
            <h4 class="sidebar-widget-title">Related SEO Guides</h4>
            <div class="popular-posts-list">
              <div class="popular-post-item">
                <div class="popular-post-thumb">
                  <img decoding="async" loading="lazy" src="blog_seo_strategies.jpg" alt="10 SEO Strategies That Actually Work in 2026" width="65" height="65">
                </div>
                <div class="popular-post-info">
                  <h5><a href="seo-strategies.html">10 SEO Strategies That Actually Work in 2026</a></h5>
                  <span class="popular-post-date">June 5, 2026</span>
                </div>
              </div>
              <div class="popular-post-item">
                <div class="popular-post-thumb">
                  <img decoding="async" loading="lazy" src="blog_how-to-rank-in-chatgpt.jpg" alt="How to Rank in ChatGPT: Complete GEO Guide for 2026" width="65" height="65">
                </div>
                <div class="popular-post-info">
                  <h5><a href="how-to-rank-in-chatgpt.html">How to Rank in ChatGPT: Complete GEO Guide for 2026</a></h5>
                  <span class="popular-post-date">June 20, 2026</span>
                </div>
              </div>
              <div class="popular-post-item">
                <div class="popular-post-thumb">
                  <img decoding="async" loading="lazy" src="blog_image-seo-optimization-tips.png" alt="25 Image SEO Optimization Tips to Improve Google Rankings in 2026" width="65" height="65">
                </div>
                <div class="popular-post-info">
                  <h5><a href="image-seo-optimization-tips.html">25 Image SEO Optimization Tips to Improve Google Rankings in 2026</a></h5>
                  <span class="popular-post-date">July 14, 2026</span>
                </div>
              </div>
              <div class="popular-post-item">
                <div class="popular-post-thumb">
                  <img decoding="async" loading="lazy" src="blog_website-speed-optimization-techniques.jpg" alt="25 Website Speed Optimization Techniques to Improve SEO in 2026" width="65" height="65">
                </div>
                <div class="popular-post-info">
                  <h5><a href="website-speed-optimization-techniques.html">25 Website Speed Optimization Techniques to Improve SEO in 2026</a></h5>
                  <span class="popular-post-date">July 13, 2026</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Widget 2b: Secondary Articles -->
          <div class="sidebar-widget">
            <h4 class="sidebar-widget-title">Paid Search & Ads</h4>
            <div class="popular-posts-list">
              <div class="popular-post-item">
                <div class="popular-post-thumb">
                  <img decoding="async" loading="lazy" src="blog_google-ads-optimization-checklist.jpg" alt="Google Ads Optimization Checklist: 25 Ways to Improve ROAS" width="65" height="65">
                </div>
                <div class="popular-post-info">
                  <h5><a href="google-ads-optimization-checklist.html">Google Ads Optimization Checklist: 25 Ways to Improve ROAS</a></h5>
                  <span class="popular-post-date">June 20, 2026</span>
                </div>
              </div>
              <div class="popular-post-item">
                <div class="popular-post-thumb">
                  <img decoding="async" loading="lazy" src="blog_meta_ads_guide.jpg" alt="Meta Ads for Small Businesses: A Complete Guide" width="65" height="65">
                </div>
                <div class="popular-post-info">
                  <h5><a href="meta-ads-guide.html">Meta Ads for Small Businesses: A Complete Guide</a></h5>
                  <span class="popular-post-date">June 6, 2026</span>
                </div>
              </div>
            </div>
          </div>

        </aside>

      </div>

    </div>
  </main>

  <!-- Footer -->
  <footer class="footer">
    <div class="container">
      <div class="grid footer-grid">
        <div class="footer-brand">
          <h3 class="logo" style="margin-bottom: 1rem;">Balamurugan<span>.P</span></h3>
          <p>I'm Balamurugan, a Freelance Digital Marketing Specialist helping businesses improve their online presence through SEO, Google Ads, Meta Ads, and professional website design.</p>
          <div class="social-links">
            <a href="https://linkedin.com" target="_blank" class="social-icon" aria-label="LinkedIn"><svg viewBox="0 0 24 24"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.779-1.75-1.75s.784-1.75 1.75-1.75 1.75.779 1.75 1.75-.784 1.75-1.75 1.75zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg></a>
          </div>
        </div>
        <div>
          <h4>Quick Links</h4>
          <ul class="footer-links">
            <li><a href="index.html">Home</a></li>
            <li><a href="about.html">About Us</a></li>
            <li><a href="blog.html">Blog Resources</a></li>
            <li><a href="contact.html">Contact Us</a></li>
            <li><a href="sitemap.html">HTML Sitemap</a></li>
          </ul>
        </div>
        <div>
          <h4>Services</h4>
          <ul class="footer-links">
            <li><a href="seo-services.html">Search Engine Optimization</a></li>
            <li><a href="google-ads-services.html">Google Ads / PPC</a></li>
            <li><a href="meta-ads-services.html">Meta Ads Campaigns</a></li>
            <li><a href="web-design-services.html">Conversion Web Design</a></li>
          </ul>
        </div>
        <div>
          <h4>Contact & Newsletter</h4>
          <ul class="footer-contact" style="font-size: 0.9rem; margin-bottom: 1.5rem;">
            <li>
              <svg viewBox="0 0 24 24" style="width:20px; height:20px; fill:currentColor; color:var(--primary); margin-right:5px; vertical-align:middle;"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
              Chennai, Tamil Nadu, India
            </li>
            <li>
              <svg viewBox="0 0 24 24" style="width:20px; height:20px; fill:currentColor; color:var(--primary); margin-right:5px; vertical-align:middle;"><path d="M20 15.5c-1.25 0-2.45-.2-3.57-.57-.35-.11-.74-.03-1.02.24l-2.2 2.2c-2.83-1.44-5.15-3.75-6.59-6.59l2.2-2.2c.28-.28.36-.67.25-1.02C8.7 6.45 8.5 5.25 8.5 4c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1 0 9.39 7.61 17 17 17 .55 0 1-.45 1-1v-3.5c0-.55-.45-1-1-1z"/></svg>
              <a href="tel:+91 63741 91927">+91 63741 91927</a>
            </li>
          </ul>
          <form class="newsletter-form" id="newsletter-form">
            <div class="newsletter-input-group">
              <input type="email" class="newsletter-input" placeholder="Your Email Address" required aria-label="Newsletter Email">
              <button type="submit" class="newsletter-btn">Join</button>
            </div>
          </form>
        </div>
      </div>
      <div class="footer-bottom">
        <p>&copy; 2026 <a href="index.html" class="inline-link" style="color: inherit; text-decoration: none;">Balamurugan P</a>. All Rights Reserved.</p>
      </div>
    </div>
  </footer>

  <!-- Back to top -->
  <button class="back-to-top" id="back-to-top" aria-label="Scroll to top">
    <svg viewBox="0 0 24 24"><path d="M7.41 15.41L12 10.83l4.59 4.58L18 14l-6-6-6 6z"/></svg>
  </button>

  <!-- WhatsApp floating button -->
  <div class="floating-contact">
    <a href="https://wa.me/916374191927?text=Hi%20Balamurugan,%20I'd%20like%20to%20enquire%20about%20your%20digital%20marketing%20services." target="_blank" class="floating-contact-btn" aria-label="Chat with Balamurugan P. on WhatsApp">
      <svg viewBox="0 0 24 24"><path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946C.06 5.348 5.397.01 12.008.01c3.202.001 6.212 1.246 8.477 3.514 2.266 2.268 3.507 5.28 3.505 8.484-.004 6.657-5.34 11.997-11.953 11.997-2.005-.001-3.973-.502-5.731-1.456L0 24zm6.59-4.846c1.6.95 3.188 1.449 4.825 1.451 5.436 0 9.86-4.42 9.863-9.864.001-2.63-1.023-5.101-2.886-6.968C16.566 1.906 14.093.882 11.457.882 6.023.882 1.597 5.302 1.594 10.74c-.001 1.701.453 3.361 1.311 4.816L1.879 20.13l4.768-1.251zM17.487 14.4c-.299-.149-1.765-.87-2.035-.969-.27-.099-.467-.149-.662.15-.195.298-.757.969-.929 1.168-.171.199-.343.224-.642.075-.299-.15-1.265-.467-2.41-1.487-.89-.793-1.49-1.773-1.664-2.07-.174-.299-.019-.461.13-.61.134-.133.299-.349.448-.523.149-.174.199-.299.299-.498.099-.199.05-.373-.025-.522-.075-.149-.662-1.596-.907-2.193-.238-.574-.48-.496-.662-.505-.171-.007-.367-.008-.563-.008-.196 0-.514.074-.783.373-.269.299-1.029 1.007-1.029 2.457 0 1.45 1.053 2.848 1.201 3.048.149.198 2.074 3.167 5.024 4.44.702.302 1.25.483 1.677.619.705.224 1.346.193 1.853.118.565-.084 1.765-.72 2.015-1.417.25-.697.25-1.294.175-1.417-.075-.125-.27-.199-.57-.348z"/></svg>
    </a>
  </div>

  <script src="main.js"></script>
</body>
</html>
'@

# Helper to verify auth token
function Is-Authorized($headers) {
    global $secureToken
    $auth = $headers["Authorization"]
    return $auth -eq $secureToken
}

# Helper to return JSON response
function Send-Json($response, $data, $statusCode = 200) {
    $json = ConvertTo-Json $data
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($json)
    $response.StatusCode = $statusCode
    $response.ContentType = "application/json; charset=utf-8"
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
    $response.Close()
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $urlPath = $request.RawUrl
        Write-Output "$($request.HttpMethod) $urlPath"
        
        # CORS Headers
        $response.Headers.Add("Access-Control-Allow-Origin", "*")
        $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization")
        
        if ($request.HttpMethod -eq "OPTIONS") {
            $response.StatusCode = 200
            $response.Close()
            continue
        }
        
        # 1. GET /bala-admin.html or /
        if ($request.HttpMethod -eq "GET" -and ($urlPath -eq "/" -or $urlPath -eq "/bala-admin.html" -or $urlPath -eq "/admin.html")) {
            $htmlPath = "$rootDir\bala-admin.html"
            if (Test-Path $htmlPath) {
                $html = [System.IO.File]::ReadAllText($htmlPath, [System.Text.Encoding]::UTF8)
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
                $response.ContentType = "text/html; charset=utf-8"
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            } else {
                $response.StatusCode = 404
            }
            $response.Close()
            continue
        }
        
        # Helper to read request body
        $body = ""
        if ($request.HasEntityBody) {
            $reader = New-Object System.IO.StreamReader($request.InputStream, [System.Text.Encoding]::UTF8)
            $body = $reader.ReadToEnd()
            $reader.Close()
        }
        
        # 2. POST /api/login
        if ($request.HttpMethod -eq "POST" -and $urlPath -eq "/api/login") {
            $data = ConvertFrom-Json $body
            if ($data.email -eq $adminEmail -and $data.password -eq $adminPassword) {
                Send-Json $response @{ message = "Success"; token = $secureToken }
            } else {
                Send-Json $response @{ message = "Invalid email or password" } 401
            }
            continue
        }
        
        # 3. GET /api/check
        if ($request.HttpMethod -eq "GET" -and $urlPath -eq "/api/check") {
            if (Is-Authorized $request.Headers) {
                Send-Json $response @{ message = "Authenticated" }
            } else {
                Send-Json $response @{ message = "Unauthorized" } 401
            }
            continue
        }
        
        # Route authorization guard for the rest of endpoints
        if (-not (Is-Authorized $request.Headers)) {
            Send-Json $response @{ message = "Unauthorized access" } 401
            continue
        }
        
        # 4. GET /api/list-pages
        if ($request.HttpMethod -eq "GET" -and $urlPath -eq "/api/list-pages") {
            $files = Get-ChildItem -Path "$rootDir" -Filter "*.html" | Select-Object -ExpandProperty Name
            $result = @()
            foreach ($f in $files) {
                if ($f -eq 'bala-admin.html') { continue }
                $result += $f
            }
            Send-Json $response $result
            continue
        }

        # 5. POST /api/rename-page
        if ($request.HttpMethod -eq "POST" -and $urlPath -eq "/api/rename-page") {
            $data = ConvertFrom-Json $body
            $oldFile = $data.oldFile
            $newFile = $data.newFile
            
            $oldPath = "$rootDir\$oldFile"
            $newPath = "$rootDir\$newFile"
            
            if (Test-Path $oldPath) {
                Rename-Item $oldPath $newFile -Force
                
                $oldFinal = "$rootDir\Bala Final\$oldFile"
                if (Test-Path $oldFinal) {
                    Rename-Item $oldFinal $newFile -Force
                }
                
                # Update sitemaps & listings links
                $sitemaps = @(
                    "$rootDir\sitemap.html", "$rootDir\sitemap.xml", "$rootDir\blog.html", "$rootDir\index.html",
                    "$rootDir\Bala Final\sitemap.html", "$rootDir\Bala Final\sitemap.xml", "$rootDir\Bala Final\blog.html", "$rootDir\Bala Final\index.html"
                )
                foreach ($s in $sitemaps) {
                    if (Test-Path $s) {
                        $sc = [System.IO.File]::ReadAllText($s, [System.Text.Encoding]::UTF8)
                        $sc = $sc.Replace($oldFile, $newFile)
                        [System.IO.File]::WriteAllText($s, $sc, [System.Text.Encoding]::UTF8)
                    }
                }
                
                # Re-sync listings & rebuild pipeline
                if (Test-Path "$rootDir\update_website_listings_10.ps1") { powershell -ExecutionPolicy Bypass -File "$rootDir\update_website_listings_10.ps1" }
                if (Test-Path "$rootDir\run_full_pipeline.ps1") { powershell -ExecutionPolicy Bypass -File "$rootDir\run_full_pipeline.ps1" }
                
                Send-Json $response @{ message = "Success" }
            } else {
                Send-Json $response @{ message = "Source file not found" } 404
            }
            continue
        }

        # 6. GET /api/get-page
        if ($request.HttpMethod -eq "GET" -and $urlPath -match "/api/get-page") {
            $file = ""
            if ($urlPath -match "file=([^&]+)") {
                $file = $Matches[1]
            }
            
            $path = "$rootDir\$file"
            if (Test-Path $path) {
                $html = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
                Send-Json $response @{ html = $html }
            } else {
                Send-Json $response @{ message = "File not found" } 404
            }
            continue
        }
        
        # 7. POST /api/save-page
        if ($request.HttpMethod -eq "POST" -and $urlPath -eq "/api/save-page") {
            $data = ConvertFrom-Json $body
            $file = $data.file
            $html = $data.html
            
            [System.IO.File]::WriteAllText("$rootDir\$file", $html, [System.Text.Encoding]::UTF8)
            [System.IO.File]::WriteAllText("$rootDir\Bala Final\$file", $html, [System.Text.Encoding]::UTF8)
            
            # Rebuild grid & pipeline
            if (Test-Path "$rootDir\update_website_listings_10.ps1") { powershell -ExecutionPolicy Bypass -File "$rootDir\update_website_listings_10.ps1" }
            if (Test-Path "$rootDir\run_full_pipeline.ps1") { powershell -ExecutionPolicy Bypass -File "$rootDir\run_full_pipeline.ps1" }
            
            Send-Json $response @{ message = "Success" }
            continue
        }
        
        # 8. POST /api/publish-blog
        if ($request.HttpMethod -eq "POST" -and $urlPath -eq "/api/publish-blog") {
            $data = ConvertFrom-Json $body
            $title = $data.title
            $slug = $data.slug
            $description = $data.description
            $category = $data.category
            $readtime = $data.readtime
            $imageDataUrl = $data.image
            $articleContent = $data.content
            
            # Save Image
            $imgExt = "jpg"
            if ($imageDataUrl -match '^data:image/([^;]+);base64,(.*)$') {
                $imgExt = $Matches[1]
                $base64Data = $Matches[2]
                $imageBytes = [System.Convert]::FromBase64String($base64Data)
                $imgName = "blog_$($slug).$imgExt"
                [System.IO.File]::WriteAllBytes("$rootDir\$imgName", $imageBytes)
                [System.IO.File]::WriteAllBytes("$rootDir\Bala Final\$imgName", $imageBytes)
            }
            
            # Setup Metadata
            $catName = "SEO"
            $catUrl = "seo-services.html"
            $breadcrumb = "SEO Guides"
            if ($category -eq "ads") {
                $catName = "Paid Search & Ads"
                $catUrl = "google-ads-services.html"
                $breadcrumb = "Ads & Campaigns"
            } elseif ($category -eq "design") {
                $catName = "Web Design"
                $catUrl = "web-design-services.html"
                $breadcrumb = "Web Design Guides"
            }
            
            $today = (Get-Date).ToString("MMMM d, yyyy")
            
            # Replace template tokens
            $pageHtml = $blogTemplate
            $pageHtml = $pageHtml.Replace("{{TITLE}}", $title)
            $pageHtml = $pageHtml.Replace("{{DESCRIPTION}}", $description)
            $pageHtml = $pageHtml.Replace("{{BREADCRUMB}}", $breadcrumb)
            $pageHtml = $pageHtml.Replace("{{CATEGORY_URL}}", $catUrl)
            $pageHtml = $pageHtml.Replace("{{CATEGORY_NAME}}", $catName)
            $pageHtml = $pageHtml.Replace("{{DATE}}", $today)
            $pageHtml = $pageHtml.Replace("{{READTIME}}", $readtime)
            $pageHtml = $pageHtml.Replace("{{IMAGE}}", $imgName)
            
            $processedContent = [regex]::Replace($articleContent, '(?<!href="[^"]*|href=''[^'']*)Balamurugan\s+P', '<a href="index.html" class="inline-link">Balamurugan P</a>')
            $processedContent = [regex]::Replace($processedContent, '(?<!href="[^"]*|href=''[^'']*)balamurugan\.in', '<a href="index.html" class="inline-link">balamurugan.in</a>')
            $pageHtml = $pageHtml.Replace("{{CONTENT}}", $processedContent)
            
            [System.IO.File]::WriteAllText("$rootDir\$($slug).html", $pageHtml, [System.Text.Encoding]::UTF8)
            [System.IO.File]::WriteAllText("$rootDir\Bala Final\$($slug).html", $pageHtml, [System.Text.Encoding]::UTF8)
            
            # Sitemaps HTML update
            $newHtmlLink = "          <li><a href=`"$($slug).html`" style=`"color: var(--text-main); text-decoration: none; transition: var(--transition-normal); font-size: 1.05rem;`" onmouseover=`"this.style.color='var(--primary)'`" onmouseout=`"this.style.color='var(--text-main)'``">$title</a></li>"
            $sitemapsHtml = @("$rootDir\Bala Final\sitemap.html", "$rootDir\sitemap.html")
            foreach ($sp in $sitemapsHtml) {
                if (Test-Path $sp) {
                    $sc = [System.IO.File]::ReadAllText($sp, [System.Text.Encoding]::UTF8)
                    if ($sc -notlike "*$slug.html*") {
                        $target = '<li><a href="ai-seo-strategies.html"'
                        if ($sc.Contains($target)) {
                            $idx = $sc.IndexOf($target)
                            $lineStartIdx = $sc.LastIndexOf("`n", $idx) + 1
                            $sc = $sc.Substring(0, $lineStartIdx) + $newHtmlLink + "`r`n" + $sc.Substring($lineStartIdx)
                            [System.IO.File]::WriteAllText($sp, $sc, [System.Text.Encoding]::UTF8)
                        }
                    }
                }
            }
            
            # Sitemaps XML update
            $newXmlNode = "`r`n  <url>`r`n    <loc>https://balamurugan.in/$($slug).html</loc>`r`n    <changefreq>monthly</changefreq>`r`n    <priority>0.6</priority>`r`n  </url>"
            $sitemapsXml = @("$rootDir\Bala Final\sitemap.xml", "$rootDir\sitemap.xml")
            foreach ($sp in $sitemapsXml) {
                if (Test-Path $sp) {
                    $sc = [System.IO.File]::ReadAllText($sp, [System.Text.Encoding]::UTF8)
                    if ($sc -notlike "*$slug.html*") {
                        $target = '</urlset>'
                        if ($sc.Contains($target)) {
                            $idx = $sc.IndexOf($target)
                            $sc = $sc.Substring(0, $idx) + $newXmlNode + "`r`n" + $sc.Substring($idx)
                            [System.IO.File]::WriteAllText($sp, $sc, [System.Text.Encoding]::UTF8)
                        }
                    }
                }
            }
            
            # Append card to blog.html grid on source file
            $blogHtmlPath = "$rootDir\blog.html"
            if (Test-Path $blogHtmlPath) {
                $blogContent = [System.IO.File]::ReadAllText($blogHtmlPath, [System.Text.Encoding]::UTF8)
                $gridTag = '<div class="grid blogs-brief-grid">'
                $idx = $blogContent.IndexOf($gridTag)
                if ($idx -ne -1) {
                    $insertIdx = $idx + $gridTag.Length
                    $newCardHtml = @"
`r`n        <div class="blog-card" data-category="$category">
          <div class="blog-img-box">
            <img decoding="async" src="$imgName" alt="$title Cover" width="1024" height="576" loading="lazy">
          </div>
          <div class="blog-content">
            <div class="blog-meta">
              <span>$today</span>
              <span>• $catName</span>
            </div>
            <h3>$title</h3>
            <p>$description</p>
            <a href="$($slug).html" class="read-more-link">
              Read Guide
              <svg viewBox="0 0 24 24"><path d="M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z"/></svg>
            </a>
          </div>
        </div>
"@
                    $blogContent = $blogContent.Substring(0, $insertIdx) + $newCardHtml + $blogContent.Substring($insertIdx)
                    [System.IO.File]::WriteAllText($blogHtmlPath, $blogContent, [System.Text.Encoding]::UTF8)
                }
            }
            
            # Trigger listings update & master pipeline
            Write-Output "Running listings updates..."
            if (Test-Path "$rootDir\update_website_listings_10.ps1") { powershell -ExecutionPolicy Bypass -File "$rootDir\update_website_listings_10.ps1" }
            Write-Output "Running master build pipeline..."
            if (Test-Path "$rootDir\run_full_pipeline.ps1") { powershell -ExecutionPolicy Bypass -File "$rootDir\run_full_pipeline.ps1" }
            
            Send-Json $response @{ message = "Success"; slug = $slug }
            continue
        }
        
        # 9. POST /api/delete
        if ($request.HttpMethod -eq "POST" -and $urlPath -eq "/api/delete") {
            $data = ConvertFrom-Json $body
            $href = $data.href
            
            if ($href) {
                $slug = $href.Replace(".html", "")
                $filesToDelete = @(
                    "$rootDir\$href",
                    "$rootDir\Bala Final\$href"
                )
                foreach ($f in $filesToDelete) {
                    if (Test-Path $f) { Remove-Item $f -Force }
                }
                
                Get-ChildItem -Path "$rootDir\" -Filter "blog_$($slug).*" | Remove-Item -Force
                Get-ChildItem -Path "$rootDir\Bala Final\" -Filter "blog_$($slug).*" | Remove-Item -Force
                
                $blogHtmlPath = "$rootDir\blog.html"
                if (Test-Path $blogHtmlPath) {
                    $blogContent = [System.IO.File]::ReadAllText($blogHtmlPath, [System.Text.Encoding]::UTF8)
                    $startTag = '<div class="grid blogs-brief-grid">'
                    $startIdx = $blogContent.IndexOf($startTag)
                    $endIdx = $blogContent.IndexOf('<!-- Pagination -->', $startIdx)
                    if ($endIdx -eq -1) { $endIdx = $blogContent.IndexOf('</section>', $startIdx) }
                    
                    if ($startIdx -ne -1 -and $endIdx -ne -1) {
                        $prefix = $blogContent.Substring(0, $startIdx + $startTag.Length)
                        $suffix = $blogContent.Substring($endIdx)
                        $gridContent = $blogContent.Substring($startIdx + $startTag.Length, $endIdx - ($startIdx + $startTag.Length))
                        
                        $parts = $gridContent -split '<div class="blog-card"'
                        $keptParts = @()
                        foreach ($part in $parts) {
                            if ([string]::IsNullOrWhiteSpace($part)) { continue }
                            if ($part -match "href=`"$href`"") { continue }
                            $keptParts += "        <div class=`"blog-card`"" + $part
                        }
                        
                        $newGridContent = "`n" + ($keptParts -join "`n") + "`n      "
                        $newBlogHtml = $prefix + $newGridContent + $suffix
                        [System.IO.File]::WriteAllText($blogHtmlPath, $newBlogHtml, [System.Text.Encoding]::UTF8)
                    }
                }
                
                $sitemapsHtml = @("$rootDir\Bala Final\sitemap.html", "$rootDir\sitemap.html")
                foreach ($sp in $sitemapsHtml) {
                    if (Test-Path $sp) {
                        $sc = [System.IO.File]::ReadAllText($sp, [System.Text.Encoding]::UTF8)
                        $linePattern = '(?m)^\s*<li><a href="' + [regex]::Escape($href) + '".*?</li>\r?\n'
                        $sc = [regex]::Replace($sc, $linePattern, "")
                        [System.IO.File]::WriteAllText($sp, $sc, [System.Text.Encoding]::UTF8)
                    }
                }
                
                $sitemapsXml = @("$rootDir\Bala Final\sitemap.xml", "$rootDir\sitemap.xml")
                foreach ($sp in $sitemapsXml) {
                    if (Test-Path $sp) {
                        $sc = [System.IO.File]::ReadAllText($sp, [System.Text.Encoding]::UTF8)
                        $blockPattern = '(?s)\s*<url>\s*<loc>https://balamurugan\.in/' + [regex]::Escape($href) + '</loc>.*?</url>'
                        $sc = [regex]::Replace($sc, $blockPattern, "")
                        [System.IO.File]::WriteAllText($sp, $sc, [System.Text.Encoding]::UTF8)
                    }
                }
                
                if (Test-Path "$rootDir\update_website_listings_10.ps1") { powershell -ExecutionPolicy Bypass -File "$rootDir\update_website_listings_10.ps1" }
                if (Test-Path "$rootDir\run_full_pipeline.ps1") { powershell -ExecutionPolicy Bypass -File "$rootDir\run_full_pipeline.ps1" }
            }
            Send-Json $response @{ message = "Success" }
            continue
        }

        # Fallback 404
        $response.StatusCode = 404
        $response.Close()
        
    } catch {
        Write-Error $_
        if ($response) {
            Send-Json $response @{ message = $_.Exception.Message } 500
        }
    }
}
