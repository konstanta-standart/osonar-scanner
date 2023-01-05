﻿#Использовать tempfiles
#Использовать fs

#Область ФС

Процедура УдалитьКаталог(Знач ПутьККаталогу, Знач пЛог) Экспорт
	
	Для ц = 1 По 5 Цикл
		
		Попытка
			
			Для каждого Файл Из НайтиФайлы(ПутьККаталогу, ПолучитьМаскуВсеФайлы(), Истина) Цикл
				Если Файл.ПолучитьТолькоЧтение() Тогда
					Файл.УстановитьТолькоЧтение(Ложь);
				КонецЕсли;
			КонецЦикла;
			УдалитьФайлы(ПутьККаталогу, ПолучитьМаскуВсеФайлы());
			пЛог.Отладка("Очищен каталог %1.", ПутьККаталогу);
			Прервать;
			
		Исключение
			пЛог.Предупреждение("Не удалось очистить каталог %1 через УдалитьФайлы. Попытка %2", ПутьККаталогу, ц);
			пЛог.Предупреждение(ОписаниеОшибки());
		КонецПопытки;
		
		пЛог.Отладка("Пауза %1с", ц);
		Приостановить(ц * 1000);

	КонецЦикла;
	
	Попытка
		УдалитьФайлы(ПутьККаталогу);
		пЛог.Отладка("Удален каталог %1.", ПутьККаталогу);
	Исключение
		пЛог.Ошибка("Не удалось удалить каталог %1.", ПутьККаталогу);
		пЛог.Ошибка(ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры

Функция ПолныйПутьККаталогу(Знач ПутьККаталогу) Экспорт
	
	полныйПуть = ФС.ПолныйПуть(ПутьККаталогу);
	
	// Удаляем последний слеш, т.к. он может экранировать кавычку и ломать строку запуска
	Пока СтрЗаканчиваетсяНа(полныйПуть, "\") Цикл
		
		полныйПуть = Лев(полныйПуть, СтрДлина(полныйПуть) - 1);

	КонецЦикла;

	Возврат полныйПуть;

КонецФункции

#КонецОбласти

Функция ОбернутьВКавычки(Знач пСтрока) Экспорт
	
	Если Лев(пСтрока, 1) = """" И Прав(пСтрока, 1) = """" Тогда
		Возврат пСтрока;
	Иначе
		Возврат """" + пСтрока + """";
	КонецЕсли;
	
КонецФункции

Функция УбратьКавычки(Знач пСтрока) Экспорт
	
	строкаБезКавычек = пСтрока;
	
	Если СтрНачинаетсяС(строкаБезКавычек, """") Тогда
		СтрокаБезКавычек = Сред(СтрокаБезКавычек, 2);
	КонецЕсли;
	
	Если СтрЗаканчиваетсяНа(строкаБезКавычек, """") Тогда
		СтрокаБезКавычек = Лев(СтрокаБезКавычек, СтрДлина(СтрокаБезКавычек) - 1);
	КонецЕсли;
	
	СтрокаБезКавычек = СтрЗаменить(СтрокаБезКавычек, """""", """");
	
	Возврат строкаБезКавычек;
	
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
	
	Если ЕстьКириллицаВСтроке(СтрокаВДос) Тогда
		// Строка уже передана в UTF-8
		Возврат СтрокаВДос;
	КонецЕсли;

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

Функция ЕстьКириллицаВСтроке(Знач СтрокаПроверки)
	
	Если Не ЗначениеЗаполнено(СтрокаПроверки) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	КодыДопустимыхСимволов = Новый Массив;
	КодыДопустимыхСимволов.Добавить(1105); // "ё"
	КодыДопустимыхСимволов.Добавить(1025); // "Ё"
	
	Для Индекс = 1 По СтрДлина(СтрокаПроверки) Цикл
		КодСимвола = КодСимвола(Сред(СтрокаПроверки, Индекс, 1));

		Если ((КодСимвола >= 1040) И (КодСимвола <= 1103)) 
			ИЛИ Не КодыДопустимыхСимволов.Найти(КодСимвола) = Неопределено Тогда
			Возврат Истина;
		КонецЕсли;

	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция ЗапуститьКоманду(Знач Команда,
						 Знач ПеременныеПроцесса = Неопределено,
							  Лог = Неопределено,
							  СкрываемыеЗначения = Неопределено) Экспорт
	
	// Стандартная библиотека всегда перехватывает вывод
	
	ПутьПриложения = Команда.ПолучитьКоманду();
	
	СтрокаЗапуска = "";
	
	Для Каждого Параметр Из Команда.ПолучитьПараметры() Цикл
		
		СтрокаЗапуска = СтрокаЗапуска + " " + Параметр;
		
	КонецЦикла;
	
	СтрокаЗапуска = ПутьПриложения + СтрокаЗапуска;
	
	СтрокаЗапуска = "cmd /c """ + СтрокаЗапуска + """";
	
	Если Не Лог = Неопределено Тогда
		
		Если СкрываемыеЗначения = Неопределено Тогда
			СкрываемыеЗначения = Новый Массив;
		КонецЕсли;
		
		Для Каждого цСкрываемоеЗначение Из СкрываемыеЗначения Цикл
			
			СтрокаЗапускаДляВывода = СтрЗаменить(СтрокаЗапуска, цСкрываемоеЗначение, "*****");
			
		КонецЦикла;
		
		Лог.Отладка("Полная строка запуска <%1>", СтрокаЗапускаДляВывода);
		
	КонецЕсли;
	
	Если ПеременныеПроцесса = Неопределено Тогда
		ПеременныеПроцесса = ПеременныеСреды();
	КонецЕсли;
	
	Процесс = СоздатьПроцесс(строкаЗапуска, ".", Ложь, Ложь, , ПеременныеПроцесса);
	
	Процесс.Запустить();
	Процесс.ОжидатьЗавершения();
	
	Возврат Процесс;
	
КонецФункции

Функция СтрокаВБулево(Знач ЗначениеИсходное) Экспорт
	
	ЗначениеБулево = НРег(ЗначениеИсходное) = "true" Или НРег(ЗначениеИсходное) = "истина";

	Возврат ЗначениеБулево;

КонецФункции
