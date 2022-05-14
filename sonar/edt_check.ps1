
if ($EDT_VERSION) {
	$EDT_VERSION_CI = $EDT_VERSION
}
else {
	$EDT_VERSION_CI = '2021.2.6'
}
Write-Host ("EDT_VERSION_CI = ") -nonewline ; Write-Host ($EDT_VERSION_CI)

$TEMP_CATALOG_EDT_CI = "$TEMP_CATALOG_CI\edt"
Write-Host ("TEMP_CATALOG_EDT_CI = ") -nonewline ; Write-Host ($TEMP_CATALOG_EDT_CI)

# Для stebi
$Env:SRC = "$Env:SRC_CATALOG_CI"
Write-Host ("SRC = ") -nonewline ; Write-Host ($Env:SRC)

$settingsPath=".\Sonar\settings.json" # Файл настройки из текущего репо
if (Test-Path -Path $settingsPath) {
	$Env:GENERIC_ISSUE_SETTINGS_JSON = $settingsPath
}
else {
	$TEMP_CATALOG_DEVOPS = "$TEMP_CATALOG_CI\devops"
	git clone "https://gitlab-ci-token:$CI_JOB_TOKEN@gitlab.com/Konstanta/devops.git" $TEMP_CATALOG_DEVOPS
	$Env:GENERIC_ISSUE_SETTINGS_JSON = "$TEMP_CATALOG_DEVOPS\Sonar\settings.json"
}
Write-Host ("GENERIC_ISSUE_SETTINGS_JSON = ") -nonewline ; Write-Host ($Env:GENERIC_ISSUE_SETTINGS_JSON)

$EDT_VALIDATION_RESULT_CSV = "$TEMP_CATALOG_EDT_CI\edt.csv"
Write-Host ("EDT_VALIDATION_RESULT_CSV = ") -nonewline ; Write-Host ($EDT_VALIDATION_RESULT_CSV)

$EDT_VALIDATION_RESULT_JSON = "$TEMP_CATALOG_EDT_CI\edt.json"
Write-Host ("EDT_VALIDATION_RESULT_JSON = ") -nonewline ; Write-Host ($EDT_VALIDATION_RESULT_JSON)

$PROJECT_PATH_EDT = "$CI_PROJECT_DIR\$PROJECT_CATALOG"
Write-Host ("PROJECT_PATH_EDT = ") -nonewline ; Write-Host ($PROJECT_PATH_EDT)

$Env:GENERIC_ISSUE_JSON = "$EDT_VALIDATION_RESULT_JSON"

$Env:RING_OPTS = "-Dfile.encoding=UTF-8 -Dosgi.nl=ru -Duser.language=ru"
Write-Host ("Env:RING_OPTS = ") -nonewline ; Write-Host ($Env:RING_OPTS)
Write-Host

# Проверка проекта по пути $PROJECT_PATH_EDT с выгрузкой в файл $EDT_VALIDATION_RESULT_CSV
$ring_args = @(
	"--workspace-location"
	"$TEMP_CATALOG_EDT_CI"
	"--project-list"
	"$PROJECT_PATH_EDT"
	"--file"
	"$EDT_VALIDATION_RESULT_CSV"
)
Write-Host ("ring_args[] = ") -nonewline ; Write-Host ($ring_args)

ring edt@$EDT_VERSION_CI workspace validate $ring_args

if (!(Test-Path -Path $EDT_VALIDATION_RESULT_CSV)) {
	Write-host ("Error. EDT validate failed. File ""edt.csv"" does not created")
	exit 1
}

# Конвертация результата проверки в json
stebi convert -e "$EDT_VALIDATION_RESULT_CSV" "$EDT_VALIDATION_RESULT_JSON"

if (!(Test-Path -Path $EDT_VALIDATION_RESULT_JSON)) {
	Write-host ("Error. stebi convert failed. File ""edt.json"" does not created")
	exit 1
}

# Трансформация результата проверки
stebi transform
