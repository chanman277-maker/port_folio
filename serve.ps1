$root = $PSScriptRoot
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:8765/")
$l.Start()
Write-Host "Serving on http://localhost:8765/"
$types = @{ ".html"="text/html; charset=utf-8"; ".jpg"="image/jpeg"; ".png"="image/png"; ".css"="text/css"; ".js"="text/javascript"; ".svg"="image/svg+xml"; ".webp"="image/webp" }
while ($l.IsListening) {
  $ctx = $l.GetContext()
  $p = [Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart('/'))
  if ($p -eq "") { $p = "index.html" }
  $f = Join-Path $root $p
  if (Test-Path $f -PathType Leaf) {
    $b = [IO.File]::ReadAllBytes($f)
    $ext = [IO.Path]::GetExtension($f)
    if ($types.ContainsKey($ext)) { $ctx.Response.ContentType = $types[$ext] }
    $ctx.Response.OutputStream.Write($b, 0, $b.Length)
  } else { $ctx.Response.StatusCode = 404 }
  $ctx.Response.Close()
}
