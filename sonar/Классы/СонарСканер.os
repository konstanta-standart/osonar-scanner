#Использовать tempfiles

Перем ПараметрыПроекта;
Перем Лог;
Перем ЭтоПроверкаЗапросаНаСлияние;

Процедура ПриСозданииОбъекта(пПараметрыПроекта, пЭтоПроверкаЗапросаНаСлияние, пЛог)
	
	Лог = пЛог;
	ПараметрыПроекта = пПараметрыПроекта;
	ЭтоПроверкаЗапросаНаСлияние = пЭтоПроверкаЗапросаНаСлияние;

КонецПроцедуры

Процедура Исполнить() Экспорт
	
	Команда = Новый Команда();
	
	Команда.УстановитьКоманду("sonar-scanner"); // берем из PATH
	
	ДобавитьВСонарПараметры_ПараметрыПроекта(Команда);
	ДобавитьВСонарПараметры_Общие(Команда);
	ДобавитьВСонарПараметры_ЗапросаНаСлияние(Команда);
	ДобавитьВСонарПараметры_ПроверкиВетки(Команда);
	ДобавитьВСонарПараметры_РезультатыПроверкиЕДТ(Команда);
	ДобавитьВСонарПараметры_Отладка(Команда);
	
	Команда.ПерехватыватьПотоки(Истина);
	Команда.ПоказыватьВыводНемедленно(Истина);
	
	переменныеСреды = ПеременныеСреды();
	переменныеСреды.Вставить("SONAR_SCANNER_OPTS", "-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF8");
	
	Команда.УстановитьПеременныеСреды(переменныеСреды);

	НачалоЗамера = ТекущаяДата();
	
	Команда.Исполнить();
	
	Лог.Информация("Работа сканера завершена за %1с", Окр(ТекущаяДата() - НачалоЗамера));
	
КонецПроцедуры

Процедура ДобавитьВСонарПараметры_ПараметрыПроекта(КомандаСканера)
	
	КомандаСканера.ДобавитьПараметр("-Dsonar.host.url=" + ПараметрыПроекта.sonar_host_url);
	КомандаСканера.ДобавитьПараметр("-Dsonar.login=" + ПараметрыПроекта.sonar_token);
	КомандаСканера.ДобавитьПараметр("-Dsonar.projectName=" + ПараметрыПроекта.projectName);
	КомандаСканера.ДобавитьПараметр("-Dsonar.projectKey=" + ПараметрыПроекта.projectKey);
	КомандаСканера.ДобавитьПараметр("-Dsonar.projectVersion=" + ПараметрыПроекта.projectVersion);
	КомандаСканера.ДобавитьПараметр("-Dsonar.sources=" + ПараметрыПроекта.Src);
	
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
	КомандаСканера.ДобавитьПараметр("-Dsonar.pullrequest.base=" + ИмяВетки("CI_MERGE_REQUEST_TARGET_BRANCH_NAME"));
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
	
	КомандаСканера.ДобавитьПараметр("-Dsonar.ExternalIssuesReportPaths=" + ПараметрыПроекта.ExternalIssuesReportPaths);
	
КонецПроцедуры

Процедура ДобавитьВСонарПараметры_Отладка(КомандаСканера)
	
	Если Не ПараметрыПроекта.Debug_Scanner Тогда
		Возврат;
	КонецЕсли;
	
	КомандаСканера.ДобавитьПараметр("-X");
	
КонецПроцедуры

#Область ИмяВетки

Функция ИмяВетки(Знач ИмяВеткиВПеременнойСреды)
	
	имяВетки = ПолучитьПеременнуюСреды(ИмяВеткиВПеременнойСреды);
	
	лог.Отладка("Имя ветки %1 = %2", ИмяВеткиВПеременнойСреды, имяВетки);
	
	имяВетки = ПерекодироватьИзДос(имяВетки);
	
	лог.Отладка("Имя ветки после перекодирования %1 = %2", ИмяВеткиВПеременнойСреды, имяВетки);
	
	Возврат имяВетки;
	
КонецФункции

Функция ПерекодироватьИзДос(Знач СтрокаВДос)
	
	ВремФайл = ВременныеФайлы.СоздатьФайл();
	
	ЗаписьТекста = Новый ЗаписьТекста(ВремФайл, КодировкаТекста.OEM);
	ЗаписьТекста.ЗаписатьСтроку(СтрокаВДос);
	ЗаписьТекста.Закрыть();
	
	ЧтениеТекста = Новый ЧтениеТекста(ВремФайл, КодировкаТекста.UTF8);
	строкаРезультат = ЧтениеТекста.ПрочитатьСтроку();
	ЧтениеТекста.Закрыть();

	УдалитьФайлы(ВремФайл);
	
	Возврат строкаРезультат;
	
КонецФункции

#КонецОбласти