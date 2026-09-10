param([string]$InputPdf, [string]$OutputPng)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Runtime.WindowsRuntime
$null = [Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]
$null = [Windows.Data.Pdf.PdfDocument, Windows.Data.Pdf, ContentType = WindowsRuntime]
$null = [Windows.Storage.Streams.InMemoryRandomAccessStream, Windows.Storage.Streams, ContentType = WindowsRuntime]
$null = [Windows.Data.Pdf.PdfPageRenderOptions, Windows.Data.Pdf, ContentType = WindowsRuntime]
$asyncMethod = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and $_.IsGenericMethod -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' } | Select-Object -First 1
function Wait-Result($Operation, $ResultType) {
    $task = $asyncMethod.MakeGenericMethod($ResultType).Invoke($null, @($Operation))
    $task.GetAwaiter().GetResult()
}
$source = Wait-Result ([Windows.Storage.StorageFile]::GetFileFromPathAsync($InputPdf)) ([Windows.Storage.StorageFile])
$document = Wait-Result ([Windows.Data.Pdf.PdfDocument]::LoadFromFileAsync($source)) ([Windows.Data.Pdf.PdfDocument])
$page = $document.GetPage(0)
$stream = [Windows.Storage.Streams.InMemoryRandomAccessStream]::new()
$options = [Windows.Data.Pdf.PdfPageRenderOptions]::new()
$options.DestinationWidth = 1191
$action = $page.RenderToStreamAsync($stream, $options)
$actionMethod = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { $_.Name -eq 'AsTask' -and -not $_.IsGenericMethod -and $_.GetParameters().Count -eq 1 } | Select-Object -First 1
$actionMethod.Invoke($null, @($action)).GetAwaiter().GetResult()
$stream.Seek(0)
$reader = [System.IO.WindowsRuntimeStreamExtensions]::AsStreamForRead($stream)
$output = [System.IO.File]::Create($OutputPng)
$reader.CopyTo($output)
$output.Dispose()
$reader.Dispose()
$stream.Dispose()
$page.Dispose()
