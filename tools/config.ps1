# ============================
# UART Engine - Configuration
# ============================

$Config = @{
    SSHHost = "ha"
    LocalComponent = Join-Path $PSScriptRoot "..\custom_components\uart_engine"
    RemoteComponents = "/config/custom_components"
    Component = "uart_engine"
    RemoteComponent = "/config/custom_components/uart_engine"
    SSH = "D:\cwrsync_6.4.8_x64_free\bin\ssh.exe"
}