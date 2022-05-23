#Использовать v8metadata-reader
#Использовать fs

Перем ПроектныеКаталоги Экспорт;
Перем ПутиКИсходникам Экспорт;

Перем Sonar_host_url Экспорт;
Перем Sonar_token Экспорт;
Перем ProjectName Экспорт;
Перем ProjectKey Экспорт;
Перем ProjectVersion Экспорт;
Перем EDT_Check Экспорт;
Перем EDT_version Экспорт;
Перем Debug_Scanner Экспорт;
Перем Debug_CI Экспорт;
Перем ExternalIssuesReportPaths Экспорт;
Перем ExternalIssuesReportSettings Экспорт;

Перем Лог;
Перем ДоступныеВерсииЕДТ;

Процедура ПриСозданииОбъекта(пЛог)
	
	Лог = пЛог;
	
	// Инициализация полей
	
	ПроектныеКаталоги = Новый Массив;
	ПутиКИсходникам = Новый Массив;
	Sonar_host_url = "";
	Sonar_token = "";
	ProjectName = "";
	ProjectKey = "";
	ProjectVersion = "";
	EDT_version = "";
	ExternalIssuesReportPaths = "";
	ExternalIssuesReportSettings = "";
	
	ЗаполнитьПараметрыПроектаИзФайлаНастроек();
	ЗаполнитьПараметрыПроектаПеременнымиСреды();
	ЗаполнитьРассчитываемыеПараметры();
	ЗаполнитьПараметрыЗначениямиПоУмолчанию();
	
	отказ = Ложь;
	
	ПроверитьПараметр("sonar_host_url", отказ);
	ПроверитьПараметр("sonar_token", отказ);
	ПроверитьПараметр("projectName", отказ);
	ПроверитьПараметр("projectKey", отказ);
	ПроверитьПараметр_Массив(ПроектныеКаталоги, "ProjectCatalog", отказ);
	ПроверитьПараметр_Массив(ПутиКИсходникам, "Src", отказ);
	ПроверитьПараметр("ProjectVersion", отказ);
	
	Если отказ Тогда
		ЗавершитьРаботу(1);
	КонецЕсли;
	
КонецПроцедуры

Функция ПутьКИсходникам() Экспорт
	
	Возврат СтрСоединить(ПутиКИсходникам, ", ");
	
КонецФункции

Процедура ЗаполнитьПараметрыПроектаИзФайлаНастроек()
	
	Лог.Отладка("Начало.Заполнение параметров из файла настроек.");
	
	параметрыИзФайла = ПрочитатьJSONФайл("./.project-settings.json");
	
	ЗаполнитьПараметрМассивИзФайлаНастроек(ПроектныеКаталоги, параметрыИзФайла["ProjectCatalog"], "ProjectCatalog");
	
	параметрыСонара = параметрыИзФайла["Sonar"];
	
	Если Не параметрыСонара = Неопределено Тогда
		
		ЗаполнитьПараметрИзФайлаНастроек("sonar_host_url", параметрыСонара["HostUrl"]);
		ЗаполнитьПараметрИзФайлаНастроек("projectName", параметрыСонара["ProjectName"]);
		ЗаполнитьПараметрИзФайлаНастроек("projectKey", параметрыСонара["ProjectKey"]);
		ЗаполнитьПараметрИзФайлаНастроек("EDT_Check", параметрыСонара["EDT_Check"]);
		ЗаполнитьПараметрИзФайлаНастроек("EDT_version", параметрыСонара["EDT_version"]);
		ЗаполнитьПараметрИзФайлаНастроек("Debug_Scanner", параметрыСонара["Debug_Scanner"]);
		ЗаполнитьПараметрИзФайлаНастроек("ExternalIssuesReportSettings", параметрыСонара["ExternalIssuesReportSettings"]);
		
	КонецЕсли;
	
	Лог.Отладка("Конец.Заполнение параметров из файла настроек.");
	
КонецПроцедуры

Функция ПрочитатьJSONФайл(Знач пИмяФайла)
	
	Если Не ФС.Существует(пИмяФайла) Тогда
		Возврат Новый Соответствие;
	КонецЕсли;
	
	ЧтениеТекста = Новый ЧтениеТекста(пИмяФайла, "UTF-8");
	Лог.Отладка("Текст из файла настроек %1", пИмяФайла);
	Лог.Отладка(ЧтениеТекста.Прочитать());
	ЧтениеТекста.Закрыть();
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.ОткрытьФайл(пИмяФайла, "UTF-8");
	
	прочитанноеЗначение = ПрочитатьJSON(ЧтениеJSON, Истина);
	
	ЧтениеJSON.Закрыть();
	
	Возврат прочитанноеЗначение;
	
КонецФункции

Процедура ЗаполнитьПараметрИзФайлаНастроек(Знач ИмяПараметра, Знач ЗначениеПараметра, Знач СкрытьЗначение = Ложь)
	
	Если ЗначениеЗаполнено(ЭтотОбъект[ИмяПараметра]) Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		
		ЭтотОбъект[ИмяПараметра] = ЗначениеПараметра;
		
		Лог.Отладка("%1 = %2 (%3)",
			ИмяПараметра,
			ОбщегоНазначения.ПредставлениеПараметра(ЗначениеПараметра, СкрытьЗначение),
			ТипЗнч(ЗначениеПараметра));
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрМассивИзФайлаНастроек(ЗаполняемыйМассив, Знач ЗначениеПараметра, Знач ПредставлениеПараметра)
	
	ЗаполнитьПараметрМассив(ЗаполняемыйМассив, ЗначениеПараметра, ПредставлениеПараметра);
	
КонецПроцедуры

Процедура ЗаполнитьПараметрыПроектаПеременнымиСреды()
	
	Лог.Отладка("Начало.Заполнение параметров из переменных среды.");
	
	ЗаполнитьПараметрМассивИзПеременнойСреды(ПроектныеКаталоги, "PROJECT_CATALOG");
	
	ЗаполнитьПараметрИзПеременнойСреды("sonar_host_url", "SONAR_HOST_URL");
	ЗаполнитьПараметрИзПеременнойСреды("sonar_token", "SONAR_TOKEN", Истина);
	ЗаполнитьПараметрИзПеременнойСреды("projectName", "PROJECT_NAME");
	ЗаполнитьПараметрИзПеременнойСреды("projectKey", "PROJECT_KEY");
	ЗаполнитьПараметрИзПеременнойСреды_Флаг("EDT_Check", "EDT_CHECK");
	ЗаполнитьПараметрИзПеременнойСреды("EDT_version", "EDT_VERSION");
	ЗаполнитьПараметрИзПеременнойСреды("ExternalIssuesReportSettings", "GENERIC_ISSUE_SETTINGS_JSON");
	ЗаполнитьПараметрИзПеременнойСреды_Флаг("Debug_Scanner", "DEBUG_SCANNER");
	ЗаполнитьПараметрИзПеременнойСреды_Флаг("Debug_CI", "DEBUG_CI");
	
	Лог.Отладка("Конец.Заполнение параметров из переменных среды.");
	
КонецПроцедуры

Процедура ЗаполнитьПараметрИзПеременнойСреды(Знач ИмяПараметра, Знач ИмяПеременнойСреды, Знач СкрытьЗначение = Ложь)
	
	Если ЗначениеЗаполнено(ЭтотОбъект[ИмяПараметра]) Тогда
		Возврат;
	КонецЕсли;
	
	значениеПараметра = ОбщегоНазначения.ПолучитьПеременнуюСреды_UTF8(ИмяПеременнойСреды, Лог, СкрытьЗначение);
	
	Если ЗначениеЗаполнено(значениеПараметра) Тогда
		
		ЭтотОбъект[ИмяПараметра] = значениеПараметра;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьПараметрМассивИзПеременнойСреды(ЗаполняемыйМассив, Знач ИмяПеременнойСреды)
	
	Если ЗаполняемыйМассив.Количество() > 0 Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьПараметрМассив(ЗаполняемыйМассив, ОбщегоНазначения.ПолучитьПеременнуюСреды_UTF8(ИмяПеременнойСреды, Лог), ИмяПеременнойСреды);
	
КонецПроцедуры

Процедура ЗаполнитьПараметрИзПеременнойСреды_Флаг(Знач ИмяПараметра, Знач ИмяПеременнойСреды)
	
	Если ЗначениеЗаполнено(ЭтотОбъект[ИмяПараметра]) Тогда
		Возврат;
	КонецЕсли;
	
	значениеПараметра = ОбщегоНазначения.ПолучитьПеременнуюСреды_UTF8(ИмяПеременнойСреды, лог);
	
	Если ЗначениеЗаполнено(значениеПараметра) Тогда
		
		значениеПараметраФлаг = ОбщегоНазначения.СтрокаВБулево(ЗначениеПараметра);
		
		ЭтотОбъект[ИмяПараметра] = значениеПараметраФлаг;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗаполнитьРассчитываемыеПараметры()
	
	Лог.Отладка("Начало.Заполнение рассчитываемых параметров.");
	
	ЗаполнитьПроектныеКаталогиПоиском();
	
	Если ПроектныеКаталоги.Количество() = 0 Тогда
		
		Лог.Ошибка("Не заполнен параметр ProjectCatalog. Продолжение невозможно.");
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	ПутиКИсходникам.Очистить();
	
	Для Каждого цКаталог Из ПроектныеКаталоги Цикл
		
		ПутиКИсходникам.Добавить(ОбъединитьПути(цКаталог, "src"));
		
	КонецЦикла;
	
	путьКИсходникам = ПутиКИсходникам[0]; // Версию берем из первого указанного проекта
	
	ИнформацияОКонфигурации = Новый ИнформацияОКонфигурации(путьКИсходникам);
	ЗаполнитьПараметрЗначениемПоУмолчанию("projectVersion", ИнформацияОКонфигурации.ВерсияКонфигурации());
	
	Если Не ЗначениеЗаполнено(ProjectVersion) Тогда
		
		Лог.Ошибка("Не удалось получить версию конфигурации из каталога %1", путьКИсходникам);
		
	КонецЕсли;
	
	Если EDT_Check Тогда
		
		ДоступныеВерсииЕДТ = ДоступныеВерсииЕДТ();
		
		Если ДоступныеВерсииЕДТ.Количество() = 0 Тогда
			
			Лог.Ошибка("Не обнаружено доступных версий ЕДТ. Проверка ЕДТ отключена");
			EDT_Check = Ложь;
			
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(EDT_version)
			И ДоступныеВерсииЕДТ.Количество() > 0 Тогда
			
			EDT_version = ДоступныеВерсииЕДТ[0];
			
			Лог.Отладка("EDT_version = <%1>. Заполнена по первой доступной версии. Все доступные версии: %2",
				EDT_version,
				СтрСоединить(ДоступныеВерсииЕДТ, ", "));
			
		КонецЕсли;
		
	КонецЕсли;
	
	Лог.Отладка("Конец.Заполнение рассчитываемых параметров.");
	
КонецПроцедуры

Процедура ЗаполнитьПараметрыЗначениямиПоУмолчанию()
	
	Лог.Отладка("Начало.Заполнение параметров по умолчанию.");
	
	ЗаполнитьПараметрЗначениемПоУмолчанию("sonar_host_url", "http://server-test:9000/");
	ЗаполнитьПараметрЗначениемПоУмолчанию("projectName", ОбщегоНазначения.ПолучитьПеременнуюСреды_UTF8("CI_PROJECT_NAME"));
	ЗаполнитьПараметрЗначениемПоУмолчанию("projectKey", "project_" + ПолучитьПеременнуюСреды("CI_PROJECT_ID"));
	ЗаполнитьПараметрЗначениемПоУмолчанию("projectVersion", "1.0.1.1");
	ЗаполнитьПараметрЗначениемПоУмолчанию("EDT_version", "2021.2.6");
	ЗаполнитьПараметрЗначениемПоУмолчанию("EDT_Check", Ложь);
	ЗаполнитьПараметрЗначениемПоУмолчанию("Debug_Scanner", Ложь);
	ЗаполнитьПараметрЗначениемПоУмолчанию("Debug_CI", Ложь);
	//TODO: Заменить на путь к приложению
	ЗаполнитьПараметрЗначениемПоУмолчанию("ExternalIssuesReportSettings", ".\gitlab_ci\sonar\settings.json");
	
	Лог.Отладка("Конец.Заполнение параметров по умолчанию.");
	
КонецПроцедуры

Процедура ЗаполнитьПараметрЗначениемПоУмолчанию(Знач ИмяПараметра, Знач значениеПараметра)
	
	Если ЗначениеЗаполнено(ЭтотОбъект[ИмяПараметра]) Тогда
		Возврат;
	КонецЕсли;
	
	ЭтотОбъект[ИмяПараметра] = значениеПараметра;
	
	Лог.Отладка("%1 = %2",
		ИмяПараметра,
		ОбщегоНазначения.ПредставлениеПараметра(значениеПараметра));
	
КонецПроцедуры

Процедура ЗаполнитьПараметрМассив(ЗаполняемыйМассив, Знач ЗначениеПараметра, Знач ПредставлениеПараметра)
	
	Если ТипЗнч(ЗначениеПараметра) = Тип("Строка") Тогда
		ЗначениеПараметра = СтрЗаменить(ЗначениеПараметра, ";", ",");
		массивЗначений = СтрРазделить(ЗначениеПараметра, ",");
	ИначеЕсли ТипЗнч(ЗначениеПараметра) = Тип("Массив") Тогда
		массивЗначений = ЗначениеПараметра;
	ИначеЕсли Не ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		Возврат;
	Иначе
		
		Лог.Ошибка("Неожиданный тип параметра %1 - %2. Ожидали Строка или Массив.", ПредставлениеПараметра, ТипЗнч(ЗначениеПараметра));
		ЗавершитьРаботу(1);
		
	КонецЕсли;
	
	Если массивЗначений.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для каждого цЗначение Из массивЗначений Цикл
		
		значениеЗаполнения = СокрЛП(цЗначение);
		
		Если ЗначениеЗаполнено(значениеЗаполнения)
			И ЗаполняемыйМассив.Найти(значениеЗаполнения) = Неопределено Тогда
			
			ЗаполняемыйМассив.Добавить(значениеЗаполнения);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Лог.Отладка("%1 = [%2]", ПредставлениеПараметра, СтрСоединить(ЗаполняемыйМассив, ", "));
	
КонецПроцедуры

Процедура ЗаполнитьПроектныеКаталогиПоиском()
	
	Если Не ПроектныеКаталоги.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Лог.Отладка("ProjectCatalog не заполнен. Попытка найти нужные каталоги в репозитории.");

	// Поиск .project. В ЕДТ там хранится информация о проекте
	
	файлыОписанийПроектов = НайтиФайлы(".", ".project", Истина);
	
	Для Каждого цНайденныйФайл Из файлыОписанийПроектов Цикл
		
		претендентНаПроектныйКаталог = цНайденныйФайл.Путь;
		
		// Проверяем наличие остальных каталогов
		
		Если ФС.Существует(ОбъединитьПути(претендентНаПроектныйКаталог, "DT-INF"))
			И ФС.Существует(ОбъединитьПути(претендентНаПроектныйКаталог, "src")) Тогда
			
			ПроектныеКаталоги.Добавить(претендентНаПроектныйКаталог);

			Лог.Отладка("	В ProjectCatalog добавлен %1", претендентНаПроектныйКаталог);
			
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПроверитьПараметр(Знач ИмяПараметра, Отказ)
	
	значениеПараметра = ЭтотОбъект[ИмяПараметра];
	
	Если Не ЗначениеЗаполнено(значениеПараметра) Тогда
		
		Лог.Ошибка("Параметр %1 не заполнен.", ИмяПараметра);
		Отказ = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПроверитьПараметр_Массив(Знач Массив, Знач ИмяПараметра, Отказ)
	
	ц = 0;
	
	Для каждого цЗначение Из Массив Цикл
		
		Если Не ЗначениеЗаполнено(цЗначение) Тогда
			
			Лог.Ошибка("Параметр %1[%2] не заполнен.", ИмяПараметра, ц);
			Отказ = Истина;
			
		КонецЕсли;
		
		ц = ц + 1;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ДоступныеВерсииЕДТ()
	
	Команда = Новый Команда();
	Команда.УстановитьСтрокуЗапуска("ring help modules");
	
	кодВозврата = Команда.Исполнить();
	
	Если Не кодВозврата = 0 Тогда
		
		Лог.Ошибка("Не удалось получить установленные версии ЕДТ");
		Лог.Ошибка(Команда.ПолучитьВывод());
		
	КонецЕсли;
	
	выводКоманды = Команда.ПолучитьВывод();
	
	началоПоиска = "edt@";
	окончаниеПоиска = ":";
	
	версии = Новый Массив;
	
	Пока Истина Цикл
		
		начальныйИндекс = СтрНайти(выводКоманды, началоПоиска, НаправлениеПоиска.СНачала, 1, версии.Количество() + 1);
		
		Если начальныйИндекс = 0 Тогда
			Прервать;
		КонецЕсли;
		
		конечныйИндекс = СтрНайти(выводКоманды, окончаниеПоиска, НаправлениеПоиска.СНачала, начальныйИндекс);
		
		Если конечныйИндекс = 0 Тогда
			Прервать;
		КонецЕсли;
		
		началоВерсии = начальныйИндекс + СтрДлина(началоПоиска);
		
		версии.Добавить(Сред(выводКоманды, началоВерсии, конечныйИндекс - началоВерсии));
		
	КонецЦикла;
	
	Лог.Отладка("	Доступные версии ЕДТ: [%1]", СтрСоединить(версии, ", "));

	Возврат версии;
	
КонецФункции