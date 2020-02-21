$primaryEventCollector = "azvmwec02"
$upEvent = Get-WinEvent Microsoft-Windows-Forwarding/Operational -FilterXPath "*[System[(EventID=104)]]" -MaxEvents 1 | Where-Object {
    $_.Message -match "http://$($primaryEventCollector)"
}
$downEvent = Get-WinEvent Microsoft-Windows-Forwarding/Operational -FilterXPath "*[System[(EventID=105)]]" -MaxEvents 1 | Where-Object {
    $_.Message -match "http://$($primaryEventCollector)"
}
# Check to see if the last Service "down" event is newer than the last service "up" event.
if ($downEvent.TimeCreated -gt $upEvent.TimeCreated)
{
    # Check to see if the other collector has been down for at least 5 minutes and that this collector service isn't already running.
    if (($downEvent.TimeCreated -lt (Get-Date).AddMinutes(-5)) -and ((Get-Service Wecsvc).Status -ne "Running"))
    {
        Write-Host "Starting Local Service..."
        Start-Service Wecsvc
    }
    # Uncomment for debugging
<#
    if ($downEvent.TimeCreated -gt (Get-Date).AddMinutes(-5))
    {
        Write-Host "Foreign collector service hasn't been down for at least 5 minutes."
    }
    if ((Get-Service Wecsvc).Status -eq "Running")
    {
        Write-Host "Local collector service is already running."
    }
#>
}
else
{
    # If the service "up" event is newer, stop the service if it's running
    if ((Get-Service Wecsvc).Status -eq "Running")
    {
        Write-Host "Stopping local service..."
        Stop-Service Wecsvc
    }
    # Uncomment for debugging
<# 
    else
    {
        Write-Host "Collector service has already been stopped."
    }
#>
}