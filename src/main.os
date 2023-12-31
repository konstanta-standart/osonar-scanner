#Использовать cmdline
#Использовать logos
#Использовать "."

Процедура ВыполнитьКоманду()
	
	Лог = Логирование.ПолучитьЛог("oscript.app.osonar-scanner");
	
	значениеПараметра = Общегоназначения.ПолучитьПеременнуюСреды_UTF8("DEBUG_CI");
	включенРежимОтладки = Общегоназначения.СтрокаВБулево(значениеПараметра);
	
	Если включенРежимОтладки Тогда
		
		Лог.УстановитьУровень(УровниЛога.Отладка);
		
		Логирование.ПолучитьЛог("oscript.lib.commands").УстановитьУровень(УровниЛога.Отладка);
		
		Лог.Информация("Включен режим отладки");
		
	КонецЕсли;
	
	Парсер = Новый ПарсерАргументовКоманднойСтроки();
	Парсер.ДобавитьПараметрФлаг("-mr");
	Парсер.ДобавитьИменованныйПараметр("-addRING_OPTS");
	
	параметры = Парсер.Разобрать(АргументыКоманднойСтроки);
	
	ЭтоПроверкаЗапросаНаСлияние = параметры["-mr"];
	допПараметрыРинга = параметры["-addRING_OPTS"];
	
	ПараметрыПроверки = Новый ПараметрыПроверки(Лог);
	
	Если НЕ ЭтоПроверкаЗапросаНаСлияние Тогда
		
		Для Каждого цКаталог Из ПараметрыПроверки.ПутиКИсходникам Цикл
			
			ПодготовитьФайлПоддержки(цКаталог);
			
		КонецЦикла;
		
	КонецЕсли;
	
	ПроверкаЕДТ = Новый ПроверкаЕДТ(ПараметрыПроверки, ЭтоПроверкаЗапросаНаСлияние, допПараметрыРинга, Лог);
	ПроверкаЕДТ.Исполнить();
	
	СонарСканер = Новый СонарСканер(ПараметрыПроверки, ЭтоПроверкаЗапросаНаСлияние, Лог);
	СонарСканер.Исполнить();
	
	ПроверкаЕДТ.ОчиститьРабочийКаталог();
	
КонецПроцедуры

Процедура ПодготовитьФайлПоддержки(Знач ПутьКИсходномуКоду)
	
	переименованныйФайлПоддержки = ОбъединитьПути(ПутьКИсходномуКоду, "Configuration", "_ParentConfigurations.bin");
	путьКФайлуПоддержки = ОбъединитьПути(ПутьКИсходномуКоду, "Configuration", "ParentConfigurations.bin");
	
	файлПоддержки = Новый Файл(переименованныйФайлПоддержки);
	
	Если файлПоддержки.Существует() Тогда
		
		КопироватьФайл(переименованныйФайлПоддержки, путьКФайлуПоддержки);
		
	КонецЕсли;
	
КонецПроцедуры

ВыполнитьКоманду();