<#
.SYNOPSIS
    Automatically synchronizes sitemap.xml and HTML sitemaps with all website pages.
.DESCRIPTION
    Scans E:\Baala\Balamurugan for HTML pages, detects new additions, and automatically
    adds them to sitemap.xml, sitemap.html, and html-sitemap.html.
#>

$repoRoot = $PSScriptRoot
if (-not $repoRoot) { $repoRoot = "E:\Baala\Balamurugan" }

$sitemapXmlPath = Join-Path $repoRoot "sitemap.xml"
$sitemapHtmlPath = Join-Path $repoRoot "sitemap.html"
$htmlSitemapPath = Join-Path $repoRoot "html-sitemap.html"

if (-not (Test-Path $sitemapXmlPath)) {
    Write-Error "sitemap.xml not found at $sitemapXmlPath"
    exit 1
}

$today = (Get-Date).ToString("yyyy-MM-dd")
$xmlContent = [System.IO.File]::ReadAllText($sitemapXmlPath)

# Excluded non-public / system / testing files
$exclude = @(
    '404.html',
    'admin.html',
    'bala-admin.html',
    'fff.html',
    'google5e19f42fae31a89a.html',
    'google8d32901e60c424f0.html',
    'menu.html',
    'thank-you.html',
    'job-portfolio.html', # Specifically blocked from indexing
    'index.html'          # Handled as root /
)

$allHtmlFiles = Get-ChildItem -Path $repoRoot -Filter "*.html" | Select-Object -ExpandProperty Name
$addedToXml = 0
$newXmlEntries = @()

foreach ($file in $allHtmlFiles) {
    if ($exclude -contains $file) { continue }
    if ($file -like "google*.html") { continue }
    if ($file -match '^(?:temp|test).*\.html$') { continue }
    
    $urlLoc = "https://balamurugan.in/$file"
    if ($xmlContent -notmatch [regex]::Escape($urlLoc)) {
        # Determine priority and changefreq based on page type
        $priority = "0.8"
        $changefreq = "monthly"
        
        if ($file -match 'services\.html') {
            $priority = "0.8"
            $changefreq = "monthly"
        } elseif ($file -match 'about\.html|contact\.html|reviews\.html') {
            $priority = "0.7"
            $changefreq = "monthly"
        } elseif ($file -match 'blog\.html') {
            $priority = "0.9"
            $changefreq = "daily"
        } elseif ($file -match 'sitemap\.html|html-sitemap\.html') {
            $priority = "0.8"
            $changefreq = "weekly"
        }

        $entry = @"
  <url>
    <loc>$urlLoc</loc>
    <lastmod>$today</lastmod>
    <changefreq>$changefreq</changefreq>
    <priority>$priority</priority>
  </url>
"@
        $newXmlEntries += $entry
        $addedToXml++
        Write-Output "Auto-detected new page for sitemap.xml: $file"
    }
}

if ($addedToXml -gt 0) {
    $target = '</urlset>'
    $idx = $xmlContent.LastIndexOf($target)
    if ($idx -gt 0) {
        $xmlContent = $xmlContent.Substring(0, $idx) + ($newXmlEntries -join "`r`n") + "`r`n" + $target + "`r`n"
        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        [System.IO.File]::WriteAllText($sitemapXmlPath, $xmlContent, $utf8NoBom)
        Write-Output "sitemap.xml successfully updated with $addedToXml new page(s)."
    }
} else {
    Write-Output "sitemap.xml is up-to-date. No new pages needed."
}

# Sync HTML sitemaps if any new blog guide was detected
$htmlSitemaps = @($sitemapHtmlPath, $htmlSitemapPath)
foreach ($sp in $htmlSitemaps) {
    if (Test-Path $sp) {
        $sContent = [System.IO.File]::ReadAllText($sp)
        $modified = $false
        
        foreach ($file in $allHtmlFiles) {
            if ($exclude -contains $file) { continue }
            if ($file -like "google*.html") { continue }
            if ($file -match '^(?:temp|test).*\.html$') { continue }
            if ($file -match 'index|about|services|contact|reviews|blog|sitemap') { continue }
            
            if ($sContent -notmatch [regex]::Escape("href=""$file""")) {
                $filePath = Join-Path $repoRoot $file
                $fText = [System.IO.File]::ReadAllText($filePath)
                $title = $file
                if ($fText -match '<title>(.*?)(?:\|.*)?</title>') {
                    $title = $matches[1].Trim()
                } elseif ($fText -match '<h1>(.*?)</h1>') {
                    $title = $matches[1].Trim() -replace '<[^>]+>', ''
                }
                
                $newLi = "            <li><a href=""$file"">$title</a></li>`r`n"
                $listStartPattern = '(?s)(<h2[^>]*>Blog Articles & Guides</h2>\s*<ul[^>]*>\r?\n)'
                if ($sContent -match $listStartPattern) {
                    $sContent = [regex]::Replace($sContent, $listStartPattern, "${1}$newLi", 1)
                    $modified = $true
                    Write-Output "Added $file to $(Split-Path $sp -Leaf)"
                }
            }
        }
        
        if ($modified) {
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($sp, $sContent, $utf8NoBom)
        }
    }
}
