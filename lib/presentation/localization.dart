import 'dart:convert';
import 'package:flutter/material.dart';

// A few labels intentionally share the same Russian source phrase.
// ignore_for_file: equal_keys_in_map

class UiText {
  const UiText(this.ru, this.uk);
  final String ru, uk;
  String of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'uk' ? uk : ru;
}

/// Text widget that routes every user-facing literal through the current locale.
/// Unknown strings are returned unchanged, which keeps vocabulary and dynamic data intact.
class LText extends StatelessWidget {
  const LText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  @override
  Widget build(BuildContext context) => Text(
    localize(data, context),
    style: style,
    textAlign: textAlign,
    textDirection: textDirection,
    softWrap: softWrap,
    overflow: overflow,
    textScaler: textScaler,
    maxLines: maxLines,
    semanticsLabel: semanticsLabel == null
        ? null
        : localize(semanticsLabel!, context),
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
    selectionColor: selectionColor,
  );
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
  value = _repairMojibake(value);
  if (Localizations.localeOf(context).languageCode != 'uk') return value;
  final translations = <String, String>{
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
    'Английский начинается\nс маленького шага.':
        'Англійська починається\nз маленького кроку.',
    'Новые слова, знакомые смыслы. Занимайтесь в своём ритме.':
        'Нові слова, знайомі сенси. Навчайтеся у своєму ритмі.',
    'ВАША ЕЖЕДНЕВНАЯ ПРАКТИКА': 'ВАША ЩОДЕННА ПРАКТИКА',
    'Цель достигнута.\nТак держать!': 'Мету досягнуто.\nТак тримати!',
    'Всего 10 минут\nдля нового себя.': 'Усього 10 хвилин\nдля нового себе.',
    'Сегодня': 'Сьогодні',
    'Освоено': 'Опрацьовано',
    'Всего XP': 'Усього XP',
    'От первых разговоров к свободному общению':
        'Від перших розмов до вільного спілкування',
    'Основа для каждого дня': 'Основа для кожного дня',
    'Больше оттенков, больше уверенности':
        'Більше відтінків, більше впевненості',
    'Карточки доступны без интернета': 'Картки доступні без інтернету',
    'Ваша неделя': 'Ваш тиждень',
    'Сегодняшняя цель': 'Сьогоднішня мета',
    'Есть чем гордиться': 'Є чим пишатися',
    'Учимся вместе': 'Навчаємося разом',
    'Слова для вашего мира': 'Слова для вашого світу',
    'Ищите, слушайте и возвращайтесь к знакомому.':
        'Шукайте, слухайте та повертайтеся до знайомого.',
    'Слово или перевод': 'Слово або переклад',
    'Добавить перевод': 'Додати переклад',
    'Мой перевод': 'Мій переклад',
    'Показать ещё': 'Показати ще',
    'Послушать': 'Послухати',
    'Закрыть': 'Закрити',
    'Насколько легко вспомнилось?': 'Наскільки легко згадалося?',
    'Снова': 'Знову',
    'Трудно': 'Важко',
    'Помню': 'Пам’ятаю',
    'Легко': 'Легко',
    'Показать перевод': 'Показати переклад',
    'Вспомните значение слова': 'Згадайте значення слова',
    'Прогресс сохраняется после каждого ответа':
        'Прогрес зберігається після кожної відповіді',
    'Произнести слово': 'Вимовити слово',
  };
  final repaired = {
    for (final entry in translations.entries)
      _repairMojibake(entry.key): _repairMojibake(entry.value),
  };
  return repaired[value] ?? value;
}

String _repairMojibake(String value) {
  if (!value.contains('Ð') && !value.contains('Ñ')) return value;
  const cp1252 = {
    '€': 0x80,
    '‚': 0x82,
    'ƒ': 0x83,
    '„': 0x84,
    '…': 0x85,
    '†': 0x86,
    '‡': 0x87,
    'ˆ': 0x88,
    '‰': 0x89,
    'Š': 0x8a,
    '‹': 0x8b,
    'Œ': 0x8c,
    'Ž': 0x8e,
    '‘': 0x91,
    '’': 0x92,
    '“': 0x93,
    '”': 0x94,
    '•': 0x95,
    '–': 0x96,
    '—': 0x97,
    '˜': 0x98,
    '™': 0x99,
    'š': 0x9a,
    '›': 0x9b,
    'œ': 0x9c,
    'ž': 0x9e,
    'Ÿ': 0x9f,
  };
  final bytes = <int>[];
  for (final char in value.runes) {
    final symbol = String.fromCharCode(char);
    final replacement = cp1252[symbol];
    if (replacement != null) {
      bytes.add(replacement);
    } else if (char <= 0xff) {
      bytes.add(char);
    } else {
      return value;
    }
  }
  return utf8.decode(bytes, allowMalformed: true);
}
