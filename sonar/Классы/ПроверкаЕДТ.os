#Использовать 1commands
#Использовать tempfiles
#Использовать fs

Перем ПараметрыПроекта;
Перем Лог;

Перем ПолныйПутьКРабочейОбласти;
Перем ПолныйПутьКФайлуРезультата;
Перем ПолныйПутьККаталогуПроекта;

Процедура ПриСозданииОбъекта(пПараметрыПроекта, пЛог)
	
	Лог = пЛог;
	ПараметрыПроекта = пПараметрыПроекта;
	
КонецПроцедуры

Процедура Исполнить() Экспорт
	
	Если Не ПараметрыПроекта.EDT_Check Тогда
		Лог.Отладка("Проверка ЕДТ пропущена. EDT_Check=Ложь.");
		Возврат;
	КонецЕсли;
	
	ПодготовитьОкружение();
	ПроверкаЕДТ();
	Конвертация();
	Трансформация();
	ОчиститьОкружение();
	
КонецПроцедуры

Процедура ПодготовитьОкружение()
	
	каталогПроверки = ОбъединитьПути("build", "edt");
	
	ФС.ОбеспечитьПустойКаталог(каталогПроверки);
	
	имяФайлаРезультата = ОбъединитьПути(каталогПроверки, "edt.tsv");
	ПараметрыПроекта.ExternalIssuesReportPaths = ОбъединитьПути(каталогПроверки, "edt.json");
	рабочаяОбласть = ВременныеФайлы.СоздатьКаталог("ws");
	
	СоздатьКаталог(рабочаяОбласть);
	
	ПолныйПутьКРабочейОбласти = ОбщегоНазначения.ПолныйПутьККаталогу(рабочаяОбласть);
	ПолныйПутьКФайлуРезультата = ФС.ПолныйПуть(имяФайлаРезультата);
	
	полныеПутиККаталогу = Новый Массив;
	
	Для Каждого цКаталог Из ПараметрыПроекта.ПроектныеКаталоги Цикл
		
		полныеПутиККаталогу.Добавить(ОбщегоНазначения.ПолныйПутьККаталогу(цКаталог));

	КонецЦикла;
	
	Если полныеПутиККаталогу.Количество() = 1 Тогда
		
		ПолныйПутьККаталогуПроекта = ОбщегоНазначения.ОбернутьВКавычки(полныеПутиККаталогу[0]);

	Иначе
		
		// Для передачи нескольких проектов нужно указать их через пробел и без кавычек.
		// Иначе ринг выводит ошибку.
		// Если в путях будут пробелы, то ой.

		ПолныйПутьККаталогуПроекта = СтрСоединить(полныеПутиККаталогу, " ");
		
	КонецЕсли;

КонецПроцедуры

Процедура ОчиститьОкружение()
	
	Если ПараметрыПроекта.Debug_CI Тогда
		Возврат;
	КонецЕсли;
	
	Лог.Отладка("Удаление файла результата %1", ПолныйПутьКФайлуРезультата);
	УдалитьФайлы(ПолныйПутьКФайлуРезультата);
	
КонецПроцедуры

Процедура ПроверкаЕДТ()
	
	версияЕДТ = "";
	
	Если ЗначениеЗаполнено(ПараметрыПроекта.EDT_version) Тогда
		версияЕДТ = "@" + ПараметрыПроекта.EDT_version;
	КонецЕсли;
	
	Команда = Новый Команда;
	Команда.УстановитьСтрокуЗапуска(СтрШаблон("ring edt%1 workspace validate", версияЕДТ));
	Команда.ДобавитьПараметр("--workspace-location " + ПолныйПутьКРабочейОбласти);
	Команда.ДобавитьПараметр("--project-list " + ПолныйПутьККаталогуПроекта);
	Команда.ДобавитьПараметр("--file " + ОбщегоНазначения.ОбернутьВКавычки(ПолныйПутьКФайлуРезультата));
	
	переменныеСреды = ПеременныеСреды();
	переменныеСреды.Вставить("RING_OPTS", "-Dfile.encoding=UTF-8 -Dosgi.nl=ru -Duser.language=ru");
	
	Команда.УстановитьПеременныеСреды(переменныеСреды);
	
	НачалоЗамера = ТекущаяДата();
	
	Команда.ПерехватыватьПотоки(Истина);
	Команда.ПоказыватьВыводНемедленно(Истина);
	
	Команда.Исполнить();
	
	Лог.Информация("Проверка ЕДТ завершена за %1с", Окр(ТекущаяДата() - НачалоЗамера));
	
	Если Не ФС.Существует(ПолныйПутьКФайлуРезультата) Тогда
		
		Лог.Ошибка("Ошибка проверки ЕДТ. Файл результата не создан.");
		ЗавершитьРаботу(1);
		
	КонецЕсли;

	ОбщегоНазначения.УдалитьКаталог(ПолныйПутьКРабочейОбласти, Лог);
	
КонецПроцедуры

Процедура Конвертация()
	
	Команда = Новый Команда;
	Команда.УстановитьСтрокуЗапуска("stebi");
	Команда.ДобавитьПараметр("convert");
	Команда.ДобавитьПараметр("-e");
	Команда.ДобавитьПараметр(ОбщегоНазначения.ОбернутьВКавычки(ПолныйПутьКФайлуРезультата));
	Команда.ДобавитьПараметр(ОбщегоНазначения.ОбернутьВКавычки(ПараметрыПроекта.ExternalIssuesReportPaths));
	Команда.ДобавитьПараметр(ОбщегоНазначения.ОбернутьВКавычки(ПараметрыПроекта.ПутьКИсходникам()));
	
	НачалоЗамера = ТекущаяДата();
	
	Команда.ПерехватыватьПотоки(Истина);
	Команда.ПоказыватьВыводНемедленно(Истина);

	Если Не ПараметрыПроекта.Debug_CI Тогда
		
		переменныеСреды = ПеременныеСреды();
		переменныеСреды.Вставить("LOGOS_CONFIG", "logger.oscript.app.parseSupport=ERROR;logger.oscript.app.stebi=ERROR");
		
		Команда.УстановитьПеременныеСреды(переменныеСреды);
		
	КонецЕсли;

	Команда.Исполнить();
	
	Лог.Информация("Конвертация результатов проверки ЕДТ завершена за %1с", Окр(ТекущаяДата() - НачалоЗамера));
	
КонецПроцедуры

Процедура Трансформация()
	
	Команда = Новый Команда;
	Команда.УстановитьСтрокуЗапуска("stebi");
	Команда.ДобавитьПараметр("transform");
	Команда.ДобавитьПараметр("--src=" + ОбщегоНазначения.ОбернутьВКавычки(ПараметрыПроекта.ПутьКИсходникам()));
	Команда.ДобавитьПараметр("--settings=" + ОбщегоНазначения.ОбернутьВКавычки(ПараметрыПроекта.ExternalIssuesReportSettings));
	Команда.ДобавитьПараметр("--remove_support=0");
	Команда.ДобавитьПараметр(ОбщегоНазначения.ОбернутьВКавычки(ПараметрыПроекта.ExternalIssuesReportPaths));
	
	НачалоЗамера = ТекущаяДата();
	
	Команда.ПерехватыватьПотоки(Истина);
	Команда.ПоказыватьВыводНемедленно(Истина);
	
	Если Не ПараметрыПроекта.Debug_CI Тогда
		
		переменныеСреды = ПеременныеСреды();
		переменныеСреды.Вставить("LOGOS_CONFIG", "logger.oscript.app.parseSupport=ERROR;logger.oscript.app.stebi=ERROR");
		
		Команда.УстановитьПеременныеСреды(переменныеСреды);
		
	КонецЕсли;
	
	Команда.Исполнить();
	
	Лог.Информация("Трансформация результатов проверки ЕДТ завершена за %1с", Окр(ТекущаяДата() - НачалоЗамера));
	
КонецПроцедуры