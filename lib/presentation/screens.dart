import 'dart:math' as math;
import '../domain/services.dart';
import 'package:flutter/material.dart';
import '../application/learning_controller.dart';
import '../domain/learning.dart';
import 'app.dart';
import 'localization.dart';
export 'study_screen.dart';
export 'settings_screen.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({
    super.key,
    required this.controller,
    required this.onStudy,
    required this.onLibrary,
  });
  final LearningController controller;
  final void Function([String deck]) onStudy;
  final VoidCallback onLibrary;
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          'Английский начинается\nс маленького шага.',
          subtitle: 'Новые слова, знакомые смыслы. Занимайтесь в своём ритме.',
        ),
        const SizedBox(height: 8),
        Glass(
          opaque: c.reduceGlass,
          padding: const EdgeInsets.all(28),
          child: LayoutBuilder(
            builder: (context, size) {
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Tag('ВАША ЕЖЕДНЕВНАЯ ПРАКТИКА'),
                  const SizedBox(height: 22),
                  LText(
                    c.today >= c.goal
                        ? 'Цель достигнута.\nТак держать!'
                        : 'Всего 10 минут\nдля нового себя.',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LText(
                    c.due > 0
                        ? '${c.due} карточек ждут повторения.\nПоможем словам остаться в памяти.'
                        : 'Откройте первую карточку.\nМы подберём время для повторения.',
                    style: TextStyle(
                      height: 1.6,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: c.queue().isEmpty ? null : () => onStudy(),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: LText(localize('Начать занятие', context)),
                  ),
                  const SizedBox(height: 12),
                  LText(
                    'Карточки доступны без интернета',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
              final visual = SizedBox(
                width: 270,
                height: 270,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: .18),
                            Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -.14,
                      child: Container(
                        width: 173,
                        height: 208,
                        decoration: BoxDecoration(
                          color: const Color(0xFFB6A9EE).withValues(alpha: .6),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: .09,
                      child: Glass(
                        padding: const EdgeInsets.all(22),
                        child: SizedBox(
                          width: 132,
                          height: 166,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wb_sunny_outlined,
                                color: Color(0xFFE2AC55),
                                size: 40,
                              ),
                              const SizedBox(height: 16),
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: LText(
                                  'discover',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 7),
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: LText('открывать'),
                              ),
                              const Spacer(),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC7BEEB),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 5,
                      top: 12,
                      child: Transform.rotate(
                        angle: .15,
                        child: const _Tag('+10 XP ✨'),
                      ),
                    ),
                  ],
                ),
              );
              return size.maxWidth > 590
                  ? Row(
                      children: [
                        Expanded(child: content),
                        visual,
                      ],
                    )
                  : content;
            },
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, size) => Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _Metric(
                width: (size.maxWidth - 28) / 3,
                icon: Icons.check_circle_outline,
                value: '${c.today}/${c.goal}',
                label: 'Сегодня',
                color: const Color(0xFF7B69CA),
              ),
              _Metric(
                width: (size.maxWidth - 28) / 3,
                icon: Icons.school_outlined,
                value: '${c.learned}',
                label: 'Освоено',
                color: const Color(0xFF4A9C8E),
              ),
              _Metric(
                width: (size.maxWidth - 28) / 3,
                icon: Icons.bolt_rounded,
                value: '${c.xp}',
                label: 'Всего XP',
                color: const Color(0xFFD29448),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SectionTitle(
          'Ваша коллекция слов',
          subtitle: 'От первых разговоров к свободному общению',
          trailing: TextButton(
            onPressed: onLibrary,
            child: LText(localize('Все слова', context)),
          ),
        ),
        _Deck(
          controller: c,
          title: 'Oxford 3000',
          subtitle: 'Основа для каждого дня',
          tag: 'A1 – B2',
          advanced: false,
          color: const Color(0xFF8D7ACD),
          onTap: () => onStudy('core'),
        ),
        const SizedBox(height: 14),
        _Deck(
          controller: c,
          title: 'Oxford 5000 · +2000',
          subtitle: 'Больше оттенков, больше уверенности',
          tag: 'B2 – C1',
          advanced: true,
          color: const Color(0xFF59A998),
          onTap: () => onStudy('advanced'),
        ),
        const SizedBox(height: 16),
        LText(
          'Каталог Oxford: ${c.words.length} слов. Готовы к обучению: ${c.words.where((w) => w.translation.isNotEmpty).length}. Добавляйте переводы в словаре, чтобы расширять занятия.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 28),
        Glass(
          opaque: c.reduceGlass,
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                color: Color(0xFFD29C44),
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LText(
                  'Лучше немного каждый день, чем много раз в неделю. Повторение в нужный момент помогает запоминать надолго.',
                  style: TextStyle(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(9),
    ),
    child: LText(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: .8,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.width,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final double width;
  final IconData icon;
  final String value, label;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Glass(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          LText(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          LText(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}

class _Deck extends StatelessWidget {
  const _Deck({
    required this.controller,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.advanced,
    required this.color,
    required this.onTap,
  });
  final LearningController controller;
  final String title, subtitle, tag;
  final bool advanced;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final words = controller.words
        .where((w) => w.advanced == advanced)
        .toList();
    final studied = words
        .where((w) => controller.progress.containsKey(w.id))
        .length;
    return Glass(
      opaque: controller.reduceGlass,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.auto_stories_outlined, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LText(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LText(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: words.isEmpty ? null : onTap,
                tooltip: 'Изучать коллекцию',
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LinearProgressIndicator(
            value: words.isEmpty ? 0 : studied / words.length,
            minHeight: 5,
            borderRadius: BorderRadius.circular(5),
            color: color,
            backgroundColor: color.withValues(alpha: .12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LText(
                  '$studied из ${words.length} доступных слов',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 8),
              LText(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    required this.controller,
    required this.onStudy,
  });
  final LearningController controller;
  final void Function([String deck]) onStudy;
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String query = '', deck = 'all';
  int visibleCount = 40;
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final words = c.words
        .where(
          (w) =>
              (deck == 'all' || (deck == 'advanced') == w.advanced) &&
              '${w.word} ${w.translation}'.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          'Слова для вашего мира',
          subtitle: 'Ищите, слушайте и возвращайтесь к знакомому.',
        ),
        TextField(
          onChanged: (v) => setState(() {
            query = v;
            visibleCount = 40;
          }),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Слово или перевод',
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          children: [
            for (final item in [
              ('all', 'Все'),
              ('core', 'Oxford 3000'),
              ('advanced', 'Дополнительные 2000'),
            ])
              ChoiceChip(
                label: LText(item.$2),
                selected: deck == item.$1,
                onSelected: (_) => setState(() {
                  deck = item.$1;
                  visibleCount = 40;
                }),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Glass(
          opaque: c.reduceGlass,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.offline_pin_outlined, color: Color(0xFF4A9C8E)),
              const SizedBox(width: 12),
              Expanded(
                child: LText(
                  '${c.words.length} слов Oxford доступны офлайн. ${c.words.where((w) => w.translation.isNotEmpty).length} с переводом. Нажмите на слово, чтобы добавить свой перевод и включить его в занятия.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: c.queue(deck: deck).isEmpty
              ? null
              : () => widget.onStudy(deck),
          icon: const Icon(Icons.play_arrow_rounded),
          label: LText(localize('Учить эту коллекцию', context)),
        ),
        const SizedBox(height: 20),
        if (words.isEmpty)
          Padding(
            padding: EdgeInsets.all(30),
            child: LText(
              localize('Ничего не найдено. Попробуйте другое слово.', context),
            ),
          ),
        for (final word in words.take(visibleCount))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Glass(
              opaque: c.reduceGlass,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: LText(
                  word.word,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: LText(
                  '${word.translation.isEmpty ? 'Добавить перевод' : word.translation}  ·  ${word.level}',
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: .09),
                  child: Icon(
                    c.progress.containsKey(word.id)
                        ? Icons.check_rounded
                        : Icons.add_rounded,
                    size: 18,
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Произнести ${word.word}',
                  onPressed: () => c.speak(word.word),
                  icon: const Icon(Icons.volume_up_outlined),
                ),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: LText(word.word),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LText(word.phonetic),
                        const SizedBox(height: 12),
                        LText(word.translation),
                        const SizedBox(height: 12),
                        LText(word.example),
                        if (c.progress[word.id] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: LText(
                              'Следующее повторение: ${dayKey(c.progress[word.id]!.due.toLocal())}',
                            ),
                          ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _editTranslation(word);
                        },
                        child: LText('Мой перевод'),
                      ),
                      TextButton(
                        onPressed: () => c.speak(word.word),
                        child: LText('Послушать'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: LText('Закрыть'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (visibleCount < words.length)
          Center(
            child: TextButton(
              onPressed: () => setState(() => visibleCount += 40),
              child: LText('Показать ещё · найдено ${words.length}'),
            ),
          ),
      ],
    );
  }

  Future<void> _editTranslation(VocabularyWord word) async {
    final input = TextEditingController(text: word.translation);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: LText(word.word),
        content: TextField(
          controller: input,
          autofocus: true,
          maxLength: 250,
          decoration: const InputDecoration(
            labelText: 'Ваш перевод',
            helperText: 'Сохранится на этом устройстве',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: LText('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (input.text.trim().isNotEmpty) {
                Navigator.pop(context, input.text.trim());
              }
            },
            child: LText('Сохранить'),
          ),
        ],
      ),
    );
    // Wait for the dialog's reverse transition before disposing its text controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    input.dispose();
    if (value != null) {
      try {
        await widget.controller.saveTranslation(word.id, value);
      } catch (_) {
        widget.controller.report('Не удалось сохранить перевод.');
      }
    }
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.controller});
  final LearningController controller;
  @override
  Widget build(BuildContext context) {
    final c = controller;
    final now = DateTime.now();
    final days = List.generate(
      7,
      (i) => DateTime(now.year, now.month, now.day - 6 + i),
    );
    final counts = days
        .map((day) => c.events.where((e) => dayKey(e.at) == dayKey(day)).length)
        .toList();
    final maxCount = math.max(c.goal, counts.fold(0, math.max));
    final correct = c.events.where((e) => e.recall != Recall.again).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          'Каждый день — прогресс',
          subtitle:
              'Посмотрите, как маленькие усилия складываются в результат.',
        ),
        LayoutBuilder(
          builder: (context, size) => Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _Metric(
                width: (size.maxWidth - 28) / 3,
                icon: Icons.local_fire_department_outlined,
                value: '${c.streak}',
                label: 'Дней подряд',
                color: const Color(0xFFD29448),
              ),
              _Metric(
                width: (size.maxWidth - 28) / 3,
                icon: Icons.style_outlined,
                value: '${c.progress.length}',
                label: 'В изучении',
                color: const Color(0xFF7B69CA),
              ),
              _Metric(
                width: (size.maxWidth - 28) / 3,
                icon: Icons.check_circle_outline,
                value: c.events.isEmpty
                    ? '—'
                    : '${(correct / c.events.length * 100).round()}%',
                label: 'Вспомнили',
                color: const Color(0xFF4A9C8E),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Glass(
          opaque: c.reduceGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(
                'Ваша неделя',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              LText(
                '${counts.fold(0, (a, b) => a + b)} ответов за последние 7 дней',
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 200,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Semantics(
                          label: '${dayKey(days[i])}: ${counts[i]} ответов',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              LText(
                                '${counts[i]}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Container(
                                  width: 28,
                                  height: 125 * counts[i] / maxCount + 5,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: i == 6 ? .85 : .25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              LText(
                                [
                                  'Пн',
                                  'Вт',
                                  'Ср',
                                  'Чт',
                                  'Пт',
                                  'Сб',
                                  'Вс',
                                ][days[i].weekday - 1],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Glass(
          opaque: c.reduceGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LText(
                'Сегодняшняя цель',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: (c.today / c.goal).clamp(0, 1),
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 12),
              LText(
                '${c.today} из ${c.goal} ответов · ${c.today >= c.goal ? 'готово!' : 'вы справитесь'}',
              ),
              const SizedBox(height: 20),
              LText(
                'Освоено: ${c.learned} слов (интервал повторения от 21 дня).\nК повторению сейчас: ${c.due}.',
                style: const TextStyle(height: 1.7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key, required this.controller});
  final LearningController controller;
  @override
  Widget build(BuildContext context) {
    final c = controller;
    final badges = [
      (
        'Первый шаг',
        'Ответьте на первую карточку',
        Icons.eco_outlined,
        c.events.isNotEmpty,
      ),
      (
        'В ритме',
        'Занимайтесь 3 дня подряд',
        Icons.local_fire_department_outlined,
        _bestStreak(c.events) >= 3,
      ),
      (
        'Сила привычки',
        'Занимайтесь 7 дней подряд',
        Icons.calendar_month_outlined,
        _bestStreak(c.events) >= 7,
      ),
      (
        'Целый месяц',
        'Занимайтесь 30 дней подряд',
        Icons.workspace_premium_outlined,
        _bestStreak(c.events) >= 30,
      ),
      (
        'Исследователь',
        'Начните изучать 20 слов',
        Icons.explore_outlined,
        c.progress.length >= 20,
      ),
      ('Тысяча искр', 'Наберите 1000 XP', Icons.bolt_outlined, c.xp >= 1000),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          'Есть чем гордиться',
          subtitle:
              '${badges.where((b) => b.$4).length} из ${badges.length} значков в вашей коллекции',
        ),
        LayoutBuilder(
          builder: (context, size) => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final badge in badges)
                SizedBox(
                  width: size.maxWidth < 500
                      ? size.maxWidth
                      : (size.maxWidth - 16) / 2,
                  child: Glass(
                    opaque: c.reduceGlass,
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                (badge.$4
                                        ? const Color(0xFFEBC77B)
                                        : Colors.grey)
                                    .withValues(alpha: .16),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            badge.$3,
                            color: badge.$4
                                ? const Color(0xFFC89A37)
                                : Colors.grey,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LText(
                                badge.$1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              LText(
                                badge.$2,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          badge.$4 ? Icons.check_circle : Icons.lock_outline,
                          size: 18,
                          color: badge.$4
                              ? const Color(0xFF4A9C8E)
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const SectionTitle(
          'Учимся вместе',
          subtitle: 'Рейтинг по опыту. Ваш адрес почты всегда скрыт.',
        ),
        if (c.user == null)
          Glass(
            opaque: c.reduceGlass,
            child: const Row(
              children: [
                Icon(Icons.people_outline, size: 36),
                SizedBox(width: 18),
                Expanded(
                  child: LText(
                    'Войдите в аккаунт в настройках, чтобы участвовать в рейтинге.',
                  ),
                ),
              ],
            ),
          )
        else
          StreamBuilder<List<RankingEntry>>(
            stream: c.community!.watchRanking(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Glass(
                  child: LText(
                    'Рейтинг пока недоступен. Проверьте подключение и настройку сервера.',
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!;
              if (docs.isEmpty) {
                return const Glass(
                  child: LText(
                    'Рейтинг пока пуст. Завершите занятие — сервер добавит ваш результат.',
                  ),
                );
              }
              return Glass(
                opaque: c.reduceGlass,
                child: Column(
                  children: [
                    for (var i = 0; i < docs.length; i++)
                      ListTile(
                        leading: CircleAvatar(child: LText('${i + 1}')),
                        title: LText(
                          docs[i].uid == c.user!.uid ? 'Вы' : docs[i].name,
                        ),
                        trailing: LText('${docs[i].xp} XP'),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  int _bestStreak(List<ReviewEvent> events) {
    if (events.isEmpty) return 0;
    final days =
        events
            .map((e) => DateTime(e.at.year, e.at.month, e.at.day))
            .toSet()
            .toList()
          ..sort();
    var best = 1, current = 1;
    for (var i = 1; i < days.length; i++) {
      final previous = days[i - 1];
      current =
          days[i] == DateTime(previous.year, previous.month, previous.day + 1)
          ? current + 1
          : 1;
      best = math.max(best, current);
    }
    return best;
  }
}
