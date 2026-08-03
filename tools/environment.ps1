function Get-Environment {

    $rsync = Get-Command rsync -ErrorAction Stop

    $env = @{
        Type      = "Unknown"
        Rsync     = $rsync.Source
        Bash      = $null
        PathStyle = "native"
    }

    if ($rsync.Source -match "msys64") {

        $env.Type = "MSYS2"

        $bash = Join-Path (Split-Path $rsync.Source) "bash.exe"

        if (!(Test-Path $bash)) {
            throw "MSYS2 bash.exe not found."
        }

        $env.Bash = $bash
        $env.PathStyle = "cygdrive"

        return $env
    }

    if ($rsync.Source -match "Git") {

        $env.Type = "Git"

        $bash = Join-Path (Split-Path $rsync.Source) "bash.exe"

        if (!(Test-Path $bash)) {
            throw "Git bash.exe not found."
        }

        $env.Bash = $bash
        $env.PathStyle = "git"

        return $env
    }

    $env.Type = "Native"

    return $env
}

function Convert-ToRsyncPath {

    param(
        [string]$Path,
        [hashtable]$Environment
    )

    $path = (Resolve-Path $Path).Path.Replace("\","/")

    switch ($Environment.PathStyle) {

        "cygdrive" {

            $drive = $path.Substring(0,1).ToLower()
            $rest  = $path.Substring(2)

            return "/cygdrive/$drive$rest"
        }

        "git" {

            $drive = $path.Substring(0,1).ToLower()
            $rest  = $path.Substring(2)

            return "/$drive$rest"
        }

        default {

            return $path
        }
    }
}