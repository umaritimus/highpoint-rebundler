${manifest_path} = Resolve-Path -Path '.\manifest.json'
${manifest} = Get-Content ${manifest_path} | ConvertFrom-Json

If (Resolve-path -Path ${manifest}.path -ErrorAction SilentlyContinue) {
    ${destination} = Join-Path -Path ${manifest}.path -ChildPath ${manifest}.filename
} Else {
    Throw "Please ensure that a valid manifest.json is present"
}

If (Test-Path -Path "${Env:TEMP}\highpoint" ) {
    Set-Location -Path "${Env:TEMP}"
    Remove-Item -Path "${Env:TEMP}\highpoint" -Force -Recurse
}

${manifest}.content | Sort-Object -Property id | ForEach-Object {
    Write-Output "Processing $($_.description)"

    If (${_}.name -eq 'HPT_BUNDLE') {
        Set-Location "${Env:TEMP}"

        If (Resolve-path -Path ${_}.path -ErrorAction SilentlyContinue) {
            New-Item -ItemType Directory -Path "${Env:TEMP}" -Name "highpoint" -Force | Out-Null
            Expand-Archive `
                -Path (Resolve-path -Path ${_}.path -ErrorAction SilentlyContinue) `
                -DestinationPath "${Env:TEMP}\highpoint" `
                -Force

            Get-Item ${env:TEMP}\highpoint\HBUNDLE* | `
                Move-Item -Destination "${env:TEMP}\highpoint\HPT_BUNDLE" -Force

            Get-Item ${env:TEMP}\highpoint\HPT_BUNDLE\querytrees | `
                Move-Item -Destination "${env:TEMP}\highpoint\HPT_BUNDLE\data" -Force
            Get-Item ${env:TEMP}\highpoint\HPT_BUNDLE\dms | `
                Move-Item -Destination "${env:TEMP}\highpoint\HPT_BUNDLE\scripts" -Force
            Get-Item ${env:TEMP}\highpoint\HPT_BUNDLE\jars | `
                Move-Item -Destination "${env:TEMP}\highpoint\HPT_BUNDLE\class" -Force
            Get-Item ${env:TEMP}\highpoint\HPT_BUNDLE\ps| `
                Move-Item -Destination "${env:TEMP}\highpoint\HPT_BUNDLE\projects" -Force
            Get-Item ${env:TEMP}\highpoint\HPT_BUNDLE\projects\HBUNDLE* | `
                Move-Item -Destination "${env:TEMP}\highpoint\HPT_BUNDLE\projects\HPT_BUNDLE" -Force

            Move-Item `
                -Path "${env:TEMP}\highpoint\HPT_BUNDLE\projects\HPT_BUNDLE\HBUNDLE*.ini" `
                -Destination "${env:TEMP}\highpoint\HPT_BUNDLE\projects\HPT_BUNDLE\HPT_BUNDLE.ini" -Force

            Move-Item `
                -Path "${env:TEMP}\highpoint\HPT_BUNDLE\projects\HPT_BUNDLE\HBUNDLE*.xml" `
                -Destination "${env:TEMP}\highpoint\HPT_BUNDLE\projects\HPT_BUNDLE\HPT_BUNDLE.xml" -Force
            
            (Get-Content -Path "${env:TEMP}\highpoint\HPT_BUNDLE\projects\HPT_BUNDLE\HPT_BUNDLE.xml" -Raw) `
                | ForEach-Object {$_ -Replace "<szProjectName>HBUNDLE.*<","<szProjectName>HPT_BUNDLE<"} `
                | ForEach-Object {$_ -Replace "<szRunDtTm>.*<","<szRunDtTm>$(Get-Date -UFormat "%Y-%m-%d-%T:000000" | ForEach-Object { $_ -replace ":", "." })<"} `
                | Set-Content -Path "${env:TEMP}\highpoint\HPT_BUNDLE\projects\HPT_BUNDLE\HPT_BUNDLE.xml"

            Get-ChildItem -Path "${Env:TEMP}\highpoint\HPT_BUNDLE\scripts\HBUNDLE*" -File "*.dat" | ForEach-Object {
                Move-Item -Path "$(${_}.FullName)" -Destination "${Env:TEMP}\highpoint\HPT_BUNDLE\data\HPT_BUNDLE.DAT" -Force
            }

            Get-ChildItem -Path "${Env:TEMP}\highpoint\HPT_BUNDLE\scripts\*" -File "*.dms" | ForEach-Object {
                Move-Item -Path "$(${_}.FullName)" -Destination "${Env:TEMP}\highpoint\HPT_BUNDLE\scripts\$(${_}.Name)" -Force
                ( Get-Content "${Env:TEMP}\highpoint\HPT_BUNDLE\scripts\$(${_}.Name)" ) | `
                    ForEach-Object { 
                    ${_} `
                        -replace 'HBUNDLE.*\.dat', 'HPT_BUNDLE.dat' `
                } | `
                    Set-Content -Path "${Env:TEMP}\highpoint\HPT_BUNDLE\scripts\$(${_}.Name)" -Force
            }

            Get-Item -Path "${Env:TEMP}\highpoint\HPT_BUNDLE\dms" -ErrorAction SilentlyContinue | `
                Remove-Item -Force
            Get-ChildItem -Path "${Env:TEMP}\highpoint\HPT_BUNDLE\jars" -ErrorAction SilentlyContinue | `
                Move-Item -Destination "${Env:TEMP}\highpoint\HPT_BUNDLE\class" -Force
        }
    } ElseIf (${_}.name -in ('HPT_SB_DELIVERED_MODS','HPT_DP_DELIVERED_MODS')) {
        If (Resolve-path -Path ${_}.path -ErrorAction SilentlyContinue) {
            Expand-Archive `
                -Path (Resolve-path -Path ${_}.path -ErrorAction SilentlyContinue) `
                -DestinationPath "${Env:TEMP}\highpoint\HPT_BUNDLE\projects" `
                -Force

            (Get-Content -Path "${env:TEMP}\highpoint\HPT_BUNDLE\projects\$(${_}.name)\$(${_}.name).xml" -Raw) `
                | ForEach-Object {$_ -Replace "<szRunDtTm>.*<","<szRunDtTm>$(Get-Date -UFormat "%Y-%m-%d-%T:000000" | ForEach-Object { $_ -replace ":", "." })<"} `
                | Set-Content -Path "${env:TEMP}\highpoint\HPT_BUNDLE\projects\$(${_}.name)\$(${_}.name).xml"
        }
    } ElseIf (${_}.name -in ('HPT_ENROLLMENT')) {
        If (Resolve-path -Path ${_}.path -ErrorAction SilentlyContinue) {
            Expand-Archive `
                -Path (Resolve-path -Path ${_}.path -ErrorAction SilentlyContinue) `
                -DestinationPath "${Env:TEMP}\highpoint\HPT_BUNDLE\src\cbl\base\" `
                -Force

            Set-Content `
                -Path "${Env:TEMP}\highpoint\HPT_BUNDLE\src\cbl\base\storehp.dms" `
                -Value "-- $(Get-Date -Format o)`n`nSET LOG storehp.log;`nDELETE FROM ps_sqlstmt_tbl WHERE pgm_name LIKE 'HPP%';`n" `
                -Force

            Get-ChildItem `
                -Path "${Env:TEMP}\highpoint\HPT_BUNDLE\src\cbl\base\hpp*.dms" `
                | ForEach-Object {
                    Add-Content `
                        -Path "${Env:TEMP}\highpoint\HPT_BUNDLE\src\cbl\base\storehp.dms" `
                        -Value "RUN $(${_}.Name);" `
                        -Force
                }
        }
    }
}

Compress-Archive `
    -Path "${Env:TEMP}\highpoint\HPT_BUNDLE",${manifest_path} `
    -DestinationPath ${destination} `
    -Update
