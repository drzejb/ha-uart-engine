Write-Host "Cleaning..."

Get-ChildItem .. -Recurse `
    -Directory `
    -Filter "__pycache__" |
    Remove-Item -Force -Recurse

Get-ChildItem .. -Recurse `
    -Include *.pyc |
    Remove-Item -Force

Write-Host "Done."