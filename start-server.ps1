$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:3000/')
$listener.Start()
Write-Host 'Server running at http://localhost:3000'

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $response = $context.Response
    $requestUrl = $context.Request.Url.LocalPath
    
    if ($requestUrl -eq '/') {
        $requestUrl = '/home-design.html'
    }
    
    $filePath = Join-Path -Path '.' -ChildPath $requestUrl.TrimStart('/')
    
    if (Test-Path $filePath -PathType Leaf) {
        try {
            $content = Get-Content -Path $filePath -Raw
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        } catch {
            $response.StatusCode = 500
        }
    } else {
        $response.StatusCode = 404
    }
    
    $response.Close()
}
