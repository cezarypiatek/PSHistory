# Set execution policy
# remove no profile for cmdr
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



function Move-Location
{
    param($NewLocation)
    Set-Location $NewLocation
    $GLOBAL:LocationHistory[$(Get-Location).Path] = [datetime]::Now
    $GLOBAL:LocationHistory  | ConvertTo-Json | Out-File -FilePath $locationHistorySavePath -Encoding utf8
}

function Get-LocationHistory
{
    $GLOBAL:LocationHistory
}

function Set-HistoricalLocation
{
    $known = @()
    if($null -eq $GLOBAL:LocationHistory.Keys)
    {
        return
    }
    $recentLocations = $GLOBAL:LocationHistory.Keys | `
     ForEach-Object { New-Object psobject -Property @{Location = $_; Timestamp = $GLOBAL:LocationHistory[$_]}} | `
     Where-Object {        
        if(($known -contains $_.Location) -or [string]::IsNullOrWhiteSpace($_.Location))
            {
                $false
            }else{
                $known = $known + $_.Location
                $true
            }
     } | `
    Sort-Object -Property Timestamp -Descending | `
    Select-Object -ExpandProperty Location -First 10
    $location = menu $recentLocations
    if($null -ne $location)
    {
        Move-Location $location
    }
}


function Read-History
{
    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath))
        {
            if ($line.EndsWith('`'))
            {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines)
                {
                    "$lines`n$line"
                }
                else
                {
                    $line
                }
                continue
            }

            if ($lines)
            {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern)))
            {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()
    $history
}
function Invoke-HistoryCommand
{ 
    $history = Read-History
    $known = @()
    $lastCommands = $history |? { $_ -ne "hc" } |? {        
        if(($known -contains $_) -or [string]::IsNullOrWhiteSpace($_) -or ($_.Contains("`$")) )
            {
                $false
            }else{
                $known = $known + $_
                $true
            }
    } | Select-Object -First 10 
    
    $selectedCommand = menu $lastCommands
     if($null -ne $selectedCommand)
     {
         Invoke-Expression $selectedCommand
     }
}
Set-Alias -Name cd -Value Move-Location -Option AllScope
Set-Alias -Name hd -Value Set-HistoricalLocation -Option AllScope
Set-Alias -Name hc -Value Invoke-HistoryCommand -Option AllScope 

#TODO
#Set-PSReadLineKeyHandler -Key F7 `
#                         -BriefDescription History `
#                         -LongDescription 'Show command history' `
#                         -ScriptBlock {
#    Invoke-HistoryCommand
#}