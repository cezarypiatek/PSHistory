$locationHistorySavePath = "$($env:USERPROFILE)\locationhistory.json"
$GLOBAL:LocationHistory = @{}
if(Test-Path $locationHistorySavePath)
{
    $restoredObj = Get-Content $locationHistorySavePath -Raw | ConvertFrom-Json 
    foreach($property in $restoredObj.psobject.properties)
    {
        $GLOBAL:LocationHistory[$property.Name] = $property.Value
    }
}

function Set-HistoricalLocation
{
    [CmdletBinding()]
    param($NewLocation)
    
    Set-Location $NewLocation
    $GLOBAL:LocationHistory[$(Get-Location).Path] = [datetime]::Now
    $GLOBAL:LocationHistory  | ConvertTo-Json | Out-File -FilePath $locationHistorySavePath -Encoding utf8
}

function Show-HistoricalLocation
{
    [CmdletBinding()]
    [Alias('hd')]
    param ()

    $known = @()
    if($null -eq $GLOBAL:LocationHistory.Keys)
    {
        return
    }
    $recentLocations = $GLOBAL:LocationHistory.Keys`
        | ForEach-Object { New-Object psobject -Property @{Location = $_; Timestamp = $GLOBAL:LocationHistory[$_]}} `
        | Where-Object {        
            if(($known -contains $_.Location) -or [string]::IsNullOrWhiteSpace($_.Location))
                {
                    $false
                }else{
                    $known = $known + $_.Location
                    $true
                }
            }`
        | Sort-Object -Property Timestamp -Descending `
        | Select-Object -ExpandProperty Location -First 10

    $location = menu $recentLocations
    if($null -ne $location)
    {
        Set-HistoricalLocation $location
    }
}

Export-ModuleMember -Function Set-HistoricalLocation, Show-HistoricalLocation -Alias hd