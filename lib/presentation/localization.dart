import 'package:flutter/material.dart';

class UiText {
  const UiText(this.ru, this.uk);
  final String ru, uk;
  String of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'uk' ? uk : ru;
}

class EasyLocalizations {
  static const nav = <UiText>[
    UiText('Обучение', 'Навчання'),
    UiText('Словарь', 'Словник'),
    UiText('Прогресс', 'Прогрес'),
    UiText('Достижения', 'Досягнення'),
    UiText('Настройки', 'Налаштування'),
  ];
  static const language = UiText('Язык интерфейса', 'Мова інтерфейсу');
  static const russian = UiText('Русский', 'Російська');
  static const ukrainian = UiText('Українська', 'Українська');
}

String localize(String value, BuildContext context) {
  if (Localizations.localeOf(context).languageCode != 'uk') return value;
  const translations = <String, String>{
    'Обучение начинается с маленького шага.':
        'Навчання починається з маленького кроку.',
    'Ваша коллекция слов': 'Ваша колекція слів',
    'Слова для вашего мира': 'Слова для вашого світу',
    'Каждый день — прогресс': 'Щодня — прогрес',
    'Есть чем гордиться': 'Є чим пишатися',
    'Ваш английский. Ваши правила.': 'Ваша англійська. Ваші правила.',
    'Внешний вид': 'Вигляд',
    'Мягкие напоминания': 'М’які нагадування',
    'Начать занятие': 'Почати заняття',
    'Все слова': 'Усі слова',
    'Учить эту коллекцию': 'Вивчати цю колекцію',
    'Показать перевод': 'Показати переклад',
    'Время для себя': 'Час для себе',
  };
  return translations[value] ?? value;
}
