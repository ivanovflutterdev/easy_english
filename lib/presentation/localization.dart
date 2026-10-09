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
