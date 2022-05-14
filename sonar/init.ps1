
# В проекте гитлаб можно указать следующие переменные
# Обязательные
#	- SONAR_TOKEN
#	- PROJECT_CATALOG
# Переопределяемые
#	- SONAR_HOST_URL
#	- PROJECT_NAME
#	- PROJECT_KEY
#	- EDT_CHECK
#	- EDT_VERSION
#	- DEBUG_SCANER

if (!($SONAR_TOKEN)) {
	Write-host ("Error. Add SONAR_TOKEN in ci/cd variables on gitlab.")
	exit 1
}

if (!($PROJECT_CATALOG)) {
	Write-host ("Error. Add PROJECT_CATALOG in ci/cd variables on gitlab.")
	exit 1
}

if ($SONAR_HOST_URL){
	$Env:SONAR_HOST_URL_CI=$SONAR_HOST_URL
} else {
	$Env:SONAR_HOST_URL_CI='http://server-test:9000/'
}
Write-Host ("SONAR_HOST_URL_CI = ") -nonewline ; Write-Host ($Env:SONAR_HOST_URL_CI)

if ($PROJECT_NAME){
	$Env:PROJECT_NAME_CI=$PROJECT_NAME
} else {
	$Env:PROJECT_NAME_CI=$CI_PROJECT_NAME
}
Write-Host ("PROJECT_NAME_CI = ") -nonewline ; Write-Host ($Env:PROJECT_NAME_CI)

if ($Env:PROJECT_KEY) {
	$Env:PROJECT_KEY_CI=$Env:PROJECT_KEY
} else {
	$Env:PROJECT_KEY_CI="project_$CI_PROJECT_ID"
}
Write-Host ("PROJECT_KEY_CI = ") -nonewline ; Write-Host ($Env:PROJECT_KEY_CI)

Write-Host ("PROJECT_CATALOG = ") -nonewline ; Write-Host ($PROJECT_CATALOG)

Write-Host ("TEMP_CATALOG_CI = ") -nonewline ; Write-Host ($TEMP_CATALOG_CI)

Write-Host ("SRC_CATALOG_CI = ") -nonewline ; Write-Host ($Env:SRC_CATALOG_CI)

$Env:SRC="$Env:SRC_CATALOG_CI" # переменная окружения stebi
Write-Host ("SRC = ") -nonewline ; Write-Host ($Env:SRC)

$Env:PROJECT_VERSION_CI=$(stebi g)
$pointCountInVersion=$Env:PROJECT_VERSION_CI.Length - $Env:PROJECT_VERSION_CI.Replace('.', '').Length
if (($Env:PROJECT_VERSION_CI.Length -lt 7) -or ($Env:PROJECT_VERSION_CI.Length -gt 15) -or ($pointCountInVersion -ne 3)) {
	Write-Host ("PROJECT_VERSION_CI = ") -nonewline ; Write-Host ($Env:PROJECT_VERSION_CI)
	Write-host ("Error. Project version not defined.")
	exit 1
}
Write-Host ("PROJECT_VERSION_CI = ") -nonewline ; Write-Host ($Env:PROJECT_VERSION_CI)

if (!($Env:DEBUG_SCANER)){$Env:DEBUG_SCANER=$false}
Write-Host ("DEBUG_SCANER = ") -nonewline ; Write-Host ($Env:DEBUG_SCANER)

if (!($Env:EDT_CHECK)){$Env:EDT_CHECK=$false}
Write-Host ("EDT_CHECK = ") -nonewline ; Write-Host ($Env:EDT_CHECK)

Write-Host
