
#Использовать tempfiles

Функция ОбернутьВКавычки(Знач пСтрока) Экспорт
	
	Если Лев(пСтрока, 1) = """" И Прав(пСтрока, 1) = """" Тогда
		Возврат пСтрока;
	Иначе
		Возврат """" + пСтрока + """";
	КонецЕсли;
	
КонецФункции

Функция ПолучитьПеременнуюСреды_UTF8(Знач пИмяПеременнойСреды, пЛог = Неопределено, Знач пСкрытьЗначение = Ложь) Экспорт
	
	значениеПараметраИсходное = ПолучитьПеременнуюСреды(пИмяПеременнойСреды);
	
	Если Не ЗначениеЗаполнено(значениеПараметраИсходное) Тогда
		
		Возврат значениеПараметраИсходное;

	КонецЕсли;

	Если Не пЛог = Неопределено Тогда
		
		пЛог.Отладка("%1 = %2",
			пИмяПеременнойСреды,
			ПредставлениеПараметра(значениеПараметраИсходное, пСкрытьЗначение));

	КонецЕсли;
	
	значениеПараметраРезультат = ПерекодироватьИзДос(значениеПараметраИсходное);
	
	Если Не значениеПараметраИсходное = значениеПараметраРезультат Тогда
		
		Если Не пЛог = Неопределено Тогда
			
			пЛог.Отладка("%1 = %2 (после перекодирования в UTF-8))",
				пИмяПеременнойСреды,
				ПредставлениеПараметра(значениеПараметраРезультат, пСкрытьЗначение));

		КонецЕсли;
		
	КонецЕсли;

	Возврат значениеПараметраРезультат;

КонецФункции

Функция ПредставлениеПараметра(Знач ЗначениеПараметра, Знач Скрывать = Ложь) Экспорт
	
	Если Не ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		
		представление = "<Пусто>";
		
	ИначеЕсли Скрывать Тогда
		
		представление = "*****";
		
	Иначе
		
		представление = ЗначениеПараметра;
		
	КонецЕсли;
	
	Возврат представление;
	
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
