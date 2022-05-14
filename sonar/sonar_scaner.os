#Использовать cmdline
#Использовать 1commands
#Использовать v8metadata-reader
#Использовать logos
#Использовать configor

Перем ЭтоПроверкаЗапросаНаСлияние; // Булево - Истина=Проверяется MR, иначе првоеряется ветка
Перем Лог; // Лог - класс логирования
Перем ПараметрыПроекта; // Структура - параметры анализируемого проекта

Процедура ВыполнитьКоманду()
	
	Лог = Логирование.ПолучитьЛог("oscript.app.k2-sonar-scanner");
	
	Лог.УстановитьУровень(УровниЛога.Отладка);
	
	Парсер = Новый ПарсерАргументовКоманднойСтроки();
	Парсер.ДобавитьПараметрФлаг("-mr");
	
	параметры = Парсер.Разобрать(АргументыКоманднойСтроки);
	
	ЭтоПроверкаЗапросаНаСлияние = параметры["-mr"];
	
	ИнициализироватьПараметрыПроекта();
	
	СонарСканер();
	
КонецПроцедуры

#Область ПараметрыПроекта

Процедура СоздатьПараметрыПроекта()
	
	ПараметрыПроекта = Новый Структура;
	
	ПараметрыПроекта.Вставить("sonar_host_url", "http://server-test:9000/");
	ПараметрыПроекта.Вставить("sonar_token", ПолучитьПеременнуюСреды("SONAR_TOKEN"));
	ПараметрыПроекта.Вставить("projectName", ПолучитьПеременнуюСреды("CI_PROJECT_NAME"));
	ПараметрыПроекта.Вставить("projectKey", "project_" + ПолучитьПеременнуюСреды("$CI_PROJECT_ID"));
	ПараметрыПроекта.Вставить("projectCatalog", "");
	ПараметрыПроекта.Вставить("sources", "");
	ПараметрыПроекта.Вставить("projectVersion", "1.0.1.1");
	ПараметрыПроекта.Вставить("EDT_Check", Ложь);
	ПараметрыПроекта.Вставить("EDT_version", "2021.2.6");
	ПараметрыПроекта.Вставить("Debug_Scanner", Ложь);
	
КонецПроцедуры

Процедура ИнициализироватьПараметрыПроекта()
	
	СоздатьПараметрыПроекта();
	ЗаполнитьПараметрыПроектаПеременнымиСреды();
	ЗаполнитьПараметрыПроектаИзФайлаНастроек();
	
	отказ = Ложь;
	
	ПроверитьПараметр("sonar_host_url", отказ);
	ПроверитьПараметр("sonar_token", отказ, Истина);
	ПроверитьПараметр("projectName", отказ);
	ПроверитьПараметр("projectKey", отказ);
	ПроверитьПараметр("projectCatalog", отказ);
	
	Если отказ Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
	ПараметрыПроекта.Вставить("sources", ".\" + ПараметрыПроекта.projectCatalog + "\src");
	ПроверитьПараметр("sources", отказ);
	
	ИнформацияОКонфигурации = Новый ИнформацияОКонфигурации(ПараметрыПроекта.sources);
	
	ПараметрыПроекта.Вставить("projectVersion", ИнформацияОКонфигурации.ВерсияКонфигурации());
	
	Если Не ЗначениеЗаполнено(ПараметрыПроекта.projectVersion) Тогда
		
		Лог.Ошибка("Не удалось получить версию конфигурации из каталога %1", ПараметрыПроекта.sources);
		
	КонецЕсли;
	
	Если отказ Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрыПроектаПеременнымиСреды()
	
	ЗаполнитьПараметрИзПеременнойСреды("sonar_host_url", "SONAR_HOST_URL");
	ЗаполнитьПараметрИзПеременнойСреды("projectName", "PROJECT_NAME");
	ЗаполнитьПараметрИзПеременнойСреды("projectKey", "PROJECT_KEY");
	ЗаполнитьПараметрИзПеременнойСреды("projectCatalog", "PROJECT_CATALOG");
	ЗаполнитьПараметрИзПеременнойСреды_Флаг("EDT_Check", "EDT_CHECK");
	ЗаполнитьПараметрИзПеременнойСреды("EDT_version", "EDT_VERSION");
	ЗаполнитьПараметрИзПеременнойСреды_Флаг("Debug_Scanner", "DEBUG_SCANER"); // Сохранена опечатка для совместимости
	ЗаполнитьПараметрИзПеременнойСреды_Флаг("Debug_Scanner", "DEBUG_SCANNER"); // На случай исправления опечатки
	
КонецПроцедуры

Процедура ЗаполнитьПараметрыПроектаИзФайлаНастроек()
	
	МенеджерПараметров = Новый МенеджерПараметров();
	МенеджерПараметров.УстановитьФайлПараметров("./.project.settings");
	МенеджерПараметров.Прочитать();
	
	ЗаполнитьПараметрИзФайлаНастроек("sonar_host_url", МенеджерПараметров.Параметр("Sonar.HostUrl"));
	ЗаполнитьПараметрИзФайлаНастроек("projectName", МенеджерПараметров.Параметр("Sonar.ProjectName"));
	ЗаполнитьПараметрИзФайлаНастроек("projectKey", МенеджерПараметров.Параметр("Sonar.ProjectKey"));
	ЗаполнитьПараметрИзФайлаНастроек("projectCatalog", МенеджерПараметров.Параметр("ProjectCatalog"));
	ЗаполнитьПараметрИзФайлаНастроек("EDT_Check", МенеджерПараметров.Параметр("Sonar.EDT_Check"));
	ЗаполнитьПараметрИзФайлаНастроек("EDT_version", МенеджерПараметров.Параметр("Sonar.EDT_version"));
	ЗаполнитьПараметрИзФайлаНастроек("Debug_Scanner", МенеджерПараметров.Параметр("Sonar.Debug_Scanner"));
	
КонецПроцедуры

Процедура ЗаполнитьПараметрИзПеременнойСреды(Знач ИмяПараметра, Знач ИмяПеременнойСреды, Знач СкрытьЗначение = Ложь)
	
	значениеПараметра = ПолучитьПеременнуюСреды(ИмяПеременнойСреды);
	
	Если ЗначениеЗаполнено(значениеПараметра) Тогда
		
		ПараметрыПроекта.Вставить(ИмяПараметра, значениеПараметра);
		
		лог.Отладка("Параметр %1 заполнен из переменной среды = %2", ИмяПараметра, ПредставлениеПараметра(значениеПараметра, СкрытьЗначение));
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрИзФайлаНастроек(Знач ИмяПараметра, Знач ЗначениеПараметра, Знач СкрытьЗначение = Ложь)
	
	Если ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		
		ПараметрыПроекта.Вставить(ИмяПараметра, ЗначениеПараметра);
		
		лог.Отладка("Параметр %1 заполнен из переменной среды = %2", ИмяПараметра, ПредставлениеПараметра(ЗначениеПараметра, СкрытьЗначение));
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрИзПеременнойСреды_Флаг(Знач ИмяПараметра, Знач ИмяПеременнойСреды)
	
	значениеПараметра = ПолучитьПеременнуюСреды(ИмяПеременнойСреды);
	
	значениеПараметра = ЗначениеЗаполнено(значениеПараметра)
		И (НРег(значениеПараметра) = "true"
			ИЛИ НРег(значениеПараметра) = "истина");
	
	Если ЗначениеЗаполнено(значениеПараметра) Тогда
		
		ПараметрыПроекта.Вставить(ИмяПараметра, значениеПараметра);
		
		лог.Отладка("Параметр %1 заполнен из переменной среды = %2", ИмяПараметра, ПредставлениеПараметра(значениеПараметра));
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьПараметр(Знач ИмяПараметра, Отказ, Знач СкрытьЗначение = Ложь)
	
	значениеПараметра = ПараметрыПроекта[ИмяПараметра];
	
	Если Не ЗначениеЗаполнено(значениеПараметра) Тогда
		
		Лог.Ошибка("Параметр %1 не заполнен.", ИмяПараметра);
		Отказ = Истина;
		
	Иначе
		
		Лог.Отладка("%1 = %2", ИмяПараметра, ПредставлениеПараметра(значениеПараметра, СкрытьЗначение));
		
	КонецЕсли;
	
КонецПроцедуры

Функция ПредставлениеПараметра(Знач ЗначениеПараметра, Знач Скрывать = Ложь)
	
	Если Не ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		
		представление = "<Пусто>";
		
	ИначеЕсли Скрывать Тогда
		
		представление = "";
		
		Для ц = 1 По СтрДлина(Строка(ЗначениеПараметра)) Цикл
			представление = представление + "*";
		КонецЦикла;
		
	Иначе
		
		представление = ЗначениеПараметра;
		
	КонецЕсли;
	
	Возврат представление;
	
КонецФункции

#КонецОбласти

#Область ЗаполнениеПараметровСонара

Процедура СонарСканер()
	
	КомандаСканера = Новый Команда();
	
	КомандаСканера.УстановитьКоманду("sonar-scanner"); // берем из PATH
	
	ДобавитьВСонарПараметры_ПараметрыПроекта(КомандаСканера);
	ДобавитьВСонарПараметры_Общие(КомандаСканера);
	ДобавитьВСонарПараметры_ЗапросаНаСлияние(КомандаСканера);
	ДобавитьВСонарПараметры_ПроверкиВетки(КомандаСканера);
	ДобавитьВСонарПараметры_РезультатыПроверкиЕДТ(КомандаСканера);
	ДобавитьВСонарПараметры_Отладка(КомандаСканера);
	
	ЗапуститьКоманду(КомандаСканера);
	
КонецПроцедуры

Процедура ДобавитьВСонарПараметры_ПараметрыПроекта(КомандаСканера)
	
	КомандаСканера.ДобавитьПараметр("-Dsonar.host.url=" + ПараметрыПроекта.sonar_host_url);
	КомандаСканера.ДобавитьПараметр("-Dsonar.login=" + ПараметрыПроекта.sonar_token);
	КомандаСканера.ДобавитьПараметр("-Dsonar.projectName=" + ПараметрыПроекта.projectName);
	КомандаСканера.ДобавитьПараметр("-Dsonar.projectKey=" + ПараметрыПроекта.projectKey);
	КомандаСканера.ДобавитьПараметр("-Dsonar.projectVersion=" + ПараметрыПроекта.projectVersion);
	КомандаСканера.ДобавитьПараметр("-Dsonar.sources=" + ПараметрыПроекта.sources);
	
КонецПроцедуры

Процедура ДобавитьВСонарПараметры_Общие(КомандаСканера)
	
	КомандаСканера.ДобавитьПараметр("-Dsonar.sourceEncoding=UTF-8");
	КомандаСканера.ДобавитьПараметр("-Dsonar.inclusions=**/*.bsl");
	КомандаСканера.ДобавитьПараметр("-Dsonar.bsl.languageserver.enabled=true");
	КомандаСканера.ДобавитьПараметр("-Dfile.encoding=UTF-8");
	КомандаСканера.ДобавитьПараметр("-Dsun.jnu.encoding=UTF8");
	КомандаСканера.ДобавитьПараметр("-Dsonar.qualitygate.wait=true");
	КомандаСканера.ДобавитьПараметр("-Dsonar.scm.exclusions.disabled=true");
	КомандаСканера.ДобавитьПараметр("-Dsonar.scm.enabled=true");
	КомандаСканера.ДобавитьПараметр("-Dsonar.scm.provider=git");
	
КонецПроцедуры

Процедура ДобавитьВСонарПараметры_ЗапросаНаСлияние(КомандаСканера)
	
	Если Не ЭтоПроверкаЗапросаНаСлияние Тогда
		Возврат;
	КонецЕсли;
	
	КомандаСканера.ДобавитьПараметр("-Dsonar.scm.revision=" + ПолучитьПеременнуюСреды("CI_COMMIT_SHA"));
	КомандаСканера.ДобавитьПараметр("-Dsonar.pullrequest.key=" + ПолучитьПеременнуюСреды("CI_MERGE_REQUEST_IID"));
	КомандаСканера.ДобавитьПараметр("-Dsonar.pullrequest.base=" + ПолучитьПеременнуюСреды("CI_MERGE_REQUEST_TARGET_BRANCH_NAME"));
	КомандаСканера.ДобавитьПараметр("-Dsonar.pullrequest.branch=" + ИмяВетки("CI_MERGE_REQUEST_SOURCE_BRANCH_NAME"));
	
КонецПроцедуры

Процедура ДобавитьВСонарПараметры_ПроверкиВетки(КомандаСканера)
	
	Если ЭтоПроверкаЗапросаНаСлияние Тогда
		Возврат;
	КонецЕсли;
	
	КомандаСканера.ДобавитьПараметр("-Dsonar.branch.name=" + ИмяВетки("CI_COMMIT_REF_NAME"));
	
КонецПроцедуры

Процедура ДобавитьВСонарПараметры_РезультатыПроверкиЕДТ(КомандаСканера)
	
	Если Не ПараметрыПроекта.EDT_Check Тогда
		Возврат;
	КонецЕсли;
	
	КомандаСканера.ДобавитьПараметр("-Dsonar.externalIssuesReportPaths=" + ПолучитьПеременнуюСреды("GENERIC_ISSUE_JSON"));
	
КонецПроцедуры

Процедура ДобавитьВСонарПараметры_Отладка(КомандаСканера)
	
	Если Не ПараметрыПроекта.Debug_Scanner Тогда
		Возврат;
	КонецЕсли;
	
	КомандаСканера.ДобавитьПараметр("-X");
	
КонецПроцедуры

#КонецОбласти

#Область ИмяВетки

Функция ИмяВетки(Знач ИмяВеткиВПеременнойСреды)
	
	имяВетки = ПолучитьПеременнуюСреды(ИмяВеткиВПеременнойСреды);
	
	Если Не ЗначениеЗаполнено(имяВетки) Тогда
		
		Лог.Ошибка("Не удалось получить имя ветки из переменной среды %1", ИмяВеткиВПеременнойСреды);
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	Возврат ВЮникод(имяВетки);
	
КонецФункции

Функция Из10в16(Знач пЧисло)
	
	Разрядность = 16;
	стр16Число = "";
	
	Пока пЧисло <> 0 Цикл
		
		Поз = пЧисло % Разрядность;
		стр16Число = Сред("0123456789ABCDEF", Поз + 1, 1) + стр16Число;
		пЧисло = Цел(пЧисло / Разрядность);
		
	КонецЦикла;
	
	Возврат стр16Число;
	
КонецФункции

Функция ВЮникод(Знач Строка)
	
	КодыСимволов = Новый Массив;
	КодыСимволов.Добавить(1105); // "ё"
	КодыСимволов.Добавить(1025); // "Ё"
	
	результат = "";
	
	Для Индекс = 1 По СтрДлина(Строка) Цикл
		
		символ = Сред(Строка, Индекс, 1);
		
		КодСимвола = КодСимвола(символ);
		
		Если (КодСимвола >= 1040 И КодСимвола <= 1103)
			ИЛИ Не КодыСимволов.Найти(КодСимвола) = Неопределено Тогда
			
			результат = результат + "\u0" + Из10в16(КодСимвола);
			
		Иначе
			
			результат = результат + символ;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат результат;
	
КонецФункции


#КонецОбласти

#Область ОбщегоНазначения

Функция ЗапуститьКоманду(Знач Команда) Экспорт
	
	// Стандартная библиотека всегда перехватывает вывод
	
	ПутьПриложения = Команда.ПолучитьКоманду();
	//ПутьПриложения = ОбернутьВКавычки(ПутьПриложения);
	
	СтрокаЗапуска = "";
	
	Для Каждого Параметр Из Команда.ПолучитьПараметры() Цикл
		
		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;
		
	КонецЦикла;
	
	СтрокаЗапуска = ПутьПриложения + СтрокаЗапуска;
	
	Лог.Отладка("Полная строка запуска <%1>", СтрокаЗапуска);
	
	Процесс = СоздатьПроцесс(строкаЗапуска, ".", Ложь, Ложь, , ПеременныеСреды());
	
	Процесс.Запустить();
	Процесс.ОжидатьЗавершения();
	
	Возврат Процесс;
	
КонецФункции

Функция ОбернутьВКавычки(Знач пСтрока) Экспорт
	
	Если Лев(пСтрока, 1) = """" И Прав(пСтрока, 1) = """" Тогда
		Возврат пСтрока;
	Иначе
		Возврат """" + пСтрока + """";
	КонецЕсли;
	
КонецФункции

#КонецОбласти

ВыполнитьКоманду();