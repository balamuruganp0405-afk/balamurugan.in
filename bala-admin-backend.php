<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Secure Token Definition
$adminEmail = "balamuruganp0405@gmail.com";
$adminPassword = "Bala@6374191927";
$secureToken = hash('sha256', $adminEmail . ':' . $adminPassword . ':bala_cms_salt');

// Auth Check Helper
function isAuthorized() {
    global $secureToken;
    $authHeader = '';
    
    if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
    } elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    } else {
        $headers = function_exists('apache_request_headers') ? apache_request_headers() : array();
        if (!is_array($headers)) {
            $headers = array();
        }
        foreach ($headers as $key => $val) {
            if (strtolower($key) === 'authorization') {
                $authHeader = $val;
                break;
            }
        }
    }
    return trim($authHeader) === $secureToken;
}

// Route Handling
$action = isset($_GET['action']) ? $_GET['action'] : '';

// 1. POST login
if ($action === 'login' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = file_get_contents('php://input');
    $data = json_decode($body, true);
    
    $email = isset($data['email']) ? trim($data['email']) : '';
    $password = isset($data['password']) ? trim($data['password']) : '';
    
    if ($email === $adminEmail && $password === $adminPassword) {
        echo json_encode(array("message" => "Success", "token" => $secureToken));
        exit;
    } else {
        http_response_code(401);
        echo json_encode(array("message" => "Invalid email or password"));
        exit;
    }
}

// 2. GET check session
if ($action === 'check') {
    if (isAuthorized()) {
        echo json_encode(array("message" => "Authenticated"));
        exit;
    } else {
        http_response_code(401);
        echo json_encode(array("message" => "Unauthorized"));
        exit;
    }
}

// Ensure all other actions require authorization
if (!isAuthorized()) {
    http_response_code(401);
    echo json_encode(array("message" => "Unauthorized access"));
    exit;
}

// List of allowed files to edit (Prevents Directory Traversal)
$allowedFiles = array(
    'index.html', 'about.html', 'services.html', 'contact.html',
    'seo-services.html', 'google-ads-services.html', 'meta-ads-services.html',
    'web-design-services.html', 'blog.html', 'sitemap.html'
);

// Route: list-pages
if ($action === 'list-pages' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $files = glob(__DIR__ . "/*.html");
    $result = array();
    foreach ($files as $file) {
        $basename = basename($file);
        if ($basename === 'bala-admin.html') continue;
        $result[] = $basename;
    }
    echo json_encode($result);
    exit;
}

// Route: rename-page
if ($action === 'rename-page' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = file_get_contents('php://input');
    $data = json_decode($body, true);
    
    $oldFile = isset($data['oldFile']) ? trim($data['oldFile']) : '';
    $newFile = isset($data['newFile']) ? trim($data['newFile']) : '';
    
    if (empty($oldFile) || empty($newFile) || !preg_match('/^[a-zA-Z0-9-]+\.html$/', $oldFile) || !preg_match('/^[a-zA-Z0-9-]+\.html$/', $newFile)) {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid file names"));
        exit;
    }
    
    $oldPath = __DIR__ . '/' . $oldFile;
    $newPath = __DIR__ . '/' . $newFile;
    
    if (file_exists($oldPath)) {
        rename($oldPath, $newPath);
        
        $oldFinalPath = __DIR__ . '/Bala Final/' . $oldFile;
        $newFinalPath = __DIR__ . '/Bala Final/' . $newFile;
        if (file_exists($oldFinalPath)) {
            rename($oldFinalPath, $newFinalPath);
        }
        
        // Update references in sitemaps and listings
        $filesToUpdate = array(
            __DIR__ . '/sitemap.html',
            __DIR__ . '/sitemap.xml',
            __DIR__ . '/blog.html',
            __DIR__ . '/index.html',
            __DIR__ . '/Bala Final/sitemap.html',
            __DIR__ . '/Bala Final/sitemap.xml',
            __DIR__ . '/Bala Final/blog.html',
            __DIR__ . '/Bala Final/index.html'
        );
        
        foreach ($filesToUpdate as $f) {
            if (file_exists($f)) {
                $content = file_get_contents($f);
                $content = str_replace($oldFile, $newFile, $content);
                file_put_contents($f, $content);
            }
        }
        
        // Trigger listings & pipeline
        @shell_exec('powershell -ExecutionPolicy Bypass -File "' . __DIR__ . '/update_website_listings_10.ps1"');
        @shell_exec('powershell -ExecutionPolicy Bypass -File "' . __DIR__ . '/run_full_pipeline.ps1"');
        
        echo json_encode(array("message" => "Success"));
        exit;
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "Source file not found"));
        exit;
    }
}

// Route: delete
if ($action === 'delete' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = file_get_contents('php://input');
    $data = json_decode($body, true);
    $href = isset($data['href']) ? trim($data['href']) : '';
    
    if ($href && preg_match('/^[a-zA-Z0-9-]+\.html$/', $href)) {
        $slug = str_replace(".html", "", $href);
        
        // Delete files
        $filesToDelete = array(
            __DIR__ . '/' . $href,
            __DIR__ . '/Bala Final/' . $href
        );
        foreach ($filesToDelete as $f) {
            if (file_exists($f)) {
                unlink($f);
            }
        }
        
        // Delete image starting with blog_$slug
        $images = glob(__DIR__ . "/blog_" . $slug . ".*");
        foreach ($images as $img) { unlink($img); }
        $imagesFinal = glob(__DIR__ . "/Bala Final/blog_" . $slug . ".*");
        foreach ($imagesFinal as $img) { unlink($img); }
        
        // Remove card from blog.html
        $blogHtmlPath = __DIR__ . '/blog.html';
        if (file_exists($blogHtmlPath)) {
            $blogContent = file_get_contents($blogHtmlPath);
            $startTag = '<div class="grid blogs-brief-grid">';
            $startIdx = strpos($blogContent, $startTag);
            $endIdx = strpos($blogContent, '<!-- Pagination -->', $startIdx);
            if ($endIdx === false) { $endIdx = strpos($blogContent, '</section>', $startIdx); }
            
            if ($startIdx !== false && $endIdx !== false) {
                $prefix = substr($blogContent, 0, $startIdx + strlen($startTag));
                $suffix = substr($blogContent, $endIdx);
                $gridContent = substr($blogContent, $startIdx + strlen($startTag), $endIdx - ($startIdx + strlen($startTag)));
                
                $parts = explode('<div class="blog-card"', $gridContent);
                $keptParts = array();
                foreach ($parts as $part) {
                    if (trim($part) === '') continue;
                    if (strpos($part, 'href="' . $href . '"') !== false) continue;
                    $keptParts[] = '        <div class="blog-card"' . $part;
                }
                
                $newGridContent = "\r\n" . implode("\r\n", $keptParts) . "\r\n      ";
                $newBlogHtml = $prefix . $newGridContent . $suffix;
                file_put_contents($blogHtmlPath, $newBlogHtml);
                if (file_exists(__DIR__ . '/Bala Final')) {
                    file_put_contents(__DIR__ . '/Bala Final/blog.html', $newBlogHtml);
                }
            }
        }
        
        // Remove from sitemaps
        $sitemapsHtml = array(__DIR__ . '/sitemap.html', __DIR__ . '/Bala Final/sitemap.html');
        foreach ($sitemapsHtml as $sp) {
            if (file_exists($sp)) {
                $sc = file_get_contents($sp);
                $sc = preg_replace('/^\s*<li><a href="' . preg_quote($href, '/') . '".*?<\/li>\r?\n/m', '', $sc);
                file_put_contents($sp, $sc);
            }
        }
        
        $sitemapsXml = array(__DIR__ . '/sitemap.xml', __DIR__ . '/Bala Final/sitemap.xml');
        foreach ($sitemapsXml as $sp) {
            if (file_exists($sp)) {
                $sc = file_get_contents($sp);
                $sc = preg_replace('/\s*<url>\s*<loc>https:\/\/balamurugan\.in\/' . preg_quote($href, '/') . '<\/loc>.*?<\/url>/s', '', $sc);
                file_put_contents($sp, $sc);
            }
        }
        
        // Re-sync listings and run pipeline
        @shell_exec('powershell -ExecutionPolicy Bypass -File "' . __DIR__ . '/update_website_listings_10.ps1"');
        @shell_exec('powershell -ExecutionPolicy Bypass -File "' . __DIR__ . '/run_full_pipeline.ps1"');
        
        echo json_encode(array("message" => "Success"));
        exit;
    }
    
    http_response_code(400);
    echo json_encode(array("message" => "Invalid target file"));
    exit;
}

// 3. GET get-page content
if ($action === 'get-page' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $file = isset($_GET['file']) ? $_GET['file'] : '';
    
    $isAllowed = in_array($file, $allowedFiles);
    $isBlogFile = (preg_match('/^[a-zA-Z0-9-]+\.html$/', $file) && file_exists(__DIR__ . '/' . $file));
    
    if (!$isAllowed && !$isBlogFile) {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid file or file not found"));
        exit;
    }
    
    $filePath = __DIR__ . '/' . $file;
    if (file_exists($filePath)) {
        $html = file_get_contents($filePath);
        echo json_encode(array("html" => $html));
        exit;
    } else {
        http_response_code(404);
        echo json_encode(array("message" => "File does not exist"));
        exit;
    }
}

// 4. POST save-page content
if ($action === 'save-page' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = file_get_contents('php://input');
    $data = json_decode($body, true);
    
    $file = isset($data['file']) ? $data['file'] : '';
    $html = isset($data['html']) ? $data['html'] : '';
    
    $isAllowed = in_array($file, $allowedFiles);
    $isBlogFile = (preg_match('/^[a-zA-Z0-9-]+\.html$/', $file) && file_exists(__DIR__ . '/' . $file));
    
    if (!$isAllowed && !$isBlogFile) {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid target file"));
        exit;
    }
    
    $filePath = __DIR__ . '/' . $file;
    $finalPath = __DIR__ . '/Bala Final/' . $file;
    
    file_put_contents($filePath, $html);
    if (file_exists(__DIR__ . '/Bala Final')) {
        file_put_contents($finalPath, $html);
    }
    
    // Trigger build pipeline after editing a page to keep formatting clean
    @shell_exec('powershell -ExecutionPolicy Bypass -File "' . __DIR__ . '/update_website_listings_10.ps1"');
    @shell_exec('powershell -ExecutionPolicy Bypass -File "' . __DIR__ . '/run_full_pipeline.ps1"');
    
    echo json_encode(array("message" => "Success"));
    exit;
}

// 5. POST publish-blog
if ($action === 'publish-blog' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = file_get_contents('php://input');
    $data = json_decode($body, true);
    
    $title = isset($data['title']) ? trim($data['title']) : '';
    $slug = isset($data['slug']) ? trim($data['slug']) : '';
    $description = isset($data['description']) ? trim($data['description']) : '';
    $category = isset($data['category']) ? trim($data['category']) : '';
    $readtime = isset($data['readtime']) ? trim($data['readtime']) : '15 min read';
    $imageDataUrl = isset($data['image']) ? $data['image'] : '';
    $articleContent = isset($data['content']) ? $data['content'] : '';
    
    if (empty($title) || empty($slug) || empty($description) || empty($articleContent)) {
        http_response_code(400);
        echo json_encode(array("message" => "Missing required fields"));
        exit;
    }
    
    // Save image
    $imgExt = "jpg";
    $imgName = "blog_" . $slug . "." . $imgExt;
    if (preg_match('/^data:image\/([^;]+);base64,(.*)$/', $imageDataUrl, $matches)) {
        $imgExt = $matches[1];
        $base64Data = $matches[2];
        $imageBytes = base64_decode($base64Data);
        $imgName = "blog_" . $slug . "." . $imgExt;
        file_put_contents(__DIR__ . '/' . $imgName, $imageBytes);
        if (file_exists(__DIR__ . '/Bala Final')) {
            file_put_contents(__DIR__ . '/Bala Final/' . $imgName, $imageBytes);
        }
    }
    
    // Setup categories
    $catName = "SEO";
    $catUrl = "seo-services.html";
    $breadcrumb = "SEO Guides";
    if ($category === "ads") {
        $catName = "Paid Search & Ads";
        $catUrl = "google-ads-services.html";
        $breadcrumb = "Ads & Campaigns";
    } elseif ($category === "design") {
        $catName = "Web Design";
        $catUrl = "web-design-services.html";
        $breadcrumb = "Web Design Guides";
    }
    
    $today = date("F j, yyyy");
    
    // Use discover tips page as the template
    $templatePath = __DIR__ . '/google-discover-optimization-tips.html';
    if (file_exists($templatePath)) {
        $pageHtml = file_get_contents($templatePath);
    } else {
        $pageHtml = "<h1>{{TITLE}}</h1><div>{{CONTENT}}</div>";
    }
    
    $pageHtml = str_replace("{{TITLE}}", $title, $pageHtml);
    $pageHtml = str_replace("{{DESCRIPTION}}", $description, $pageHtml);
    $pageHtml = str_replace("{{BREADCRUMB}}", $breadcrumb, $pageHtml);
    $pageHtml = str_replace("{{CATEGORY_URL}}", $catUrl, $pageHtml);
    $pageHtml = str_replace("{{CATEGORY_NAME}}", $catName, $pageHtml);
    $pageHtml = str_replace("{{DATE}}", $today, $pageHtml);
    $pageHtml = str_replace("{{READTIME}}", $readtime, $pageHtml);
    $pageHtml = str_replace("{{IMAGE}}", $imgName, $pageHtml);
    
    $processedContent = preg_replace('/(?<!href="[^"]*|href=\'[^\']*)Balamurugan\s+P/', '<a href="index.html" class="inline-link">Balamurugan P</a>', $articleContent);
    $processedContent = preg_replace('/(?<!href="[^"]*|href=\'[^\']*)balamurugan\.in/', '<a href="index.html" class="inline-link">balamurugan.in</a>', $processedContent);
    $pageHtml = str_replace("{{CONTENT}}", $processedContent, $pageHtml);
    
    file_put_contents(__DIR__ . '/' . $slug . '.html', $pageHtml);
    if (file_exists(__DIR__ . '/Bala Final')) {
        file_put_contents(__DIR__ . '/Bala Final/' . $slug . '.html', $pageHtml);
    }
    
    // Add to sitemaps
    $newHtmlLink = "          <li><a href=\"{$slug}.html\" style=\"color: var(--text-main); text-decoration: none; transition: var(--transition-normal); font-size: 1.05rem;\" onmouseover=\"this.style.color='var(--primary)'\" onmouseout=\"this.style.color='var(--text-main)'\">$title</a></li>";
    $sitemapsHtml = array(__DIR__ . '/sitemap.html', __DIR__ . '/Bala Final/sitemap.html');
    foreach ($sitemapsHtml as $sp) {
        if (file_exists($sp)) {
            $sc = file_get_contents($sp);
            if (strpos($sc, $slug . '.html') === false) {
                $target = '<li><a href="ai-seo-strategies.html"';
                if (($pos = strpos($sc, $target)) !== false) {
                    $lineStartPos = strrpos(substr($sc, 0, $pos), "\n") + 1;
                    $sc = substr($sc, 0, $lineStartPos) . $newHtmlLink . "\r\n" . substr($sc, $lineStartPos);
                    file_put_contents($sp, $sc);
                }
            }
        }
    }
    
    $newXmlNode = "\r\n  <url>\r\n    <loc>https://balamurugan.in/{$slug}.html</loc>\r\n    <changefreq>monthly</changefreq>\r\n    <priority>0.6</priority>\r\n  </url>";
    $sitemapsXml = array(__DIR__ . '/sitemap.xml', __DIR__ . '/Bala Final/sitemap.xml');
    foreach ($sitemapsXml as $sp) {
        if (file_exists($sp)) {
            $sc = file_get_contents($sp);
            if (strpos($sc, $slug . '.html') === false) {
                $target = '</urlset>';
                if (($pos = strpos($sc, $target)) !== false) {
                    $sc = substr($sc, 0, $pos) . $newXmlNode . "\r\n" . substr($sc, $pos);
                    file_put_contents($sp, $sc);
                }
            }
        }
    }
    
    // Add to blog.html grid
    $blogHtmlPath = __DIR__ . '/blog.html';
    if (file_exists($blogHtmlPath)) {
        $blogContent = file_get_contents($blogHtmlPath);
        $gridTag = '<div class="grid blogs-brief-grid">';
        if (($pos = strpos($blogContent, $gridTag)) !== false) {
            $insertIdx = $pos + strlen($gridTag);
            $newCardHtml = "\r\n        <div class=\"blog-card\" data-category=\"$category\">\r\n          <div class=\"blog-img-box\">\r\n            <img decoding=\"async\" src=\"$imgName\" alt=\"$title Cover\" width=\"1024\" height=\"576\" loading=\"lazy\">\r\n          </div>\r\n          <div class=\"blog-content\">\r\n            <div class=\"blog-meta\">\r\n              <span>$today</span>\r\n              <span>&bull; $catName</span>\r\n            </div>\r\n            <h3>$title</h3>\r\n            <p>$description</p>\r\n            <a href=\"{$slug}.html\" class=\"read-more-link\">\r\n              Read Guide\r\n              <svg viewBox=\"0 0 24 24\"><path d=\"M12 4l-1.41 1.41L16.17 11H4v2h12.17l-5.58 5.59L12 20l8-8z\"/></svg>\r\n            </a>\r\n          </div>\r\n        </div>";
            $blogContent = substr($blogContent, 0, $insertIdx) . $newCardHtml . substr($blogContent, $insertIdx);
            file_put_contents($blogHtmlPath, $blogContent);
            if (file_exists(__DIR__ . '/Bala Final')) {
                file_put_contents(__DIR__ . '/Bala Final/blog.html', $blogContent);
            }
        }
    }
    
    @shell_exec('powershell -ExecutionPolicy Bypass -File "' . __DIR__ . '/update_website_listings_10.ps1"');
    @shell_exec('powershell -ExecutionPolicy Bypass -File "' . __DIR__ . '/run_full_pipeline.ps1"');
    
    echo json_encode(array("message" => "Success", "slug" => $slug));
    exit;
}

// 6. GET get-faqs
if ($action === 'get-faqs' && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $filePath = __DIR__ . '/faqs.json';
    if (file_exists($filePath)) {
        echo file_get_contents($filePath);
    } else {
        echo json_encode(new stdClass());
    }
    exit;
}

// 7. POST save-faqs
if ($action === 'save-faqs' && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = file_get_contents('php://input');
    
    // Validate json
    $data = json_decode($body, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid JSON data"));
        exit;
    }
    
    $filePath = __DIR__ . '/faqs.json';
    file_put_contents($filePath, $body);
    
    $finalDir = __DIR__ . '/Bala Final';
    if (file_exists($finalDir)) {
        file_put_contents($finalDir . '/faqs.json', $body);
    }
    
    echo json_encode(array("message" => "Success"));
    exit;
}

http_response_code(404);
echo json_encode(array("message" => "Action not found"));
exit;
?>
