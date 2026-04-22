# 简单的HTTP服务器
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8000/")
$listener.Start()
Write-Host "服务器已启动，访问地址: http://localhost:8000"

while ($true) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
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
    
    $response.Close()
}