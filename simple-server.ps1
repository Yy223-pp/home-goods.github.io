# 简单的HTTP服务器
$url = "http://localhost:8000/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()
Write-Host "服务器已启动，访问地址: $url"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    try {
        $filePath = $request.Url.LocalPath
        if ($filePath -eq "/") {
            $filePath = "/home-design.html"
        }
        
        $localPath = "." + $filePath
        
        if (Test-Path $localPath -PathType Leaf) {
            $content = Get-Content -Path $localPath -Raw
            $response.ContentType = "text/html"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        } else {
            $response.StatusCode = 404
            $content = "404 Not Found"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
    } catch {
        Write-Host "错误: $($_.Exception.Message)"
    } finally {
        $response.Close()
    }
}

$listener.Stop()