import 'package:flutter/material.dart';
import '../application/learning_controller.dart';
import '../domain/learning.dart';
import 'app.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.controller, required this.deck});
  final LearningController controller;
  final String deck;
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late List<VocabularyWord> cards;
  int index = 0;
  bool revealed = false, busy = false;
  late String sessionOwner;
  @override
  void initState() {
    super.initState();
    sessionOwner = widget.controller.owner;
    cards = widget.controller
        .queue(deck: widget.deck)
        .take(widget.controller.goal)
        .toList();
  }

  Future<void> answer(Recall recall) async {
    if (busy || sessionOwner != widget.controller.owner) return;
    setState(() => busy = true);
    try {
      await widget.controller.answer(cards[index], recall);
      if (mounted) {
        setState(() {
          index++;
          revealed = false;
        });
      }
    } catch (_) {
      /* Root listener displays persistence failures. */
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final done = index >= cards.length;
    final scheme = Theme.of(context).colorScheme;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          title: const Text('Время для себя'),
          centerTitle: true,
          backgroundColor: scheme.surface,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: sessionOwner != c.owner
                    ? Column(
                        children: [
                          const Text(
                            'Аккаунт изменился. Начните новое занятие.',
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Вернуться'),
                          ),
                        ],
                      )
                    : done
                    ? Column(
                        children: [
                          const Icon(
                            Icons.celebration_outlined,
                            size: 85,
                            color: Color(0xFFC6A45D),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            cards.isEmpty
                                ? 'Вы всё повторили!'
                                : 'Ещё один шаг вперёд!',
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            cards.isEmpty
                                ? 'Возвращайтесь, когда подойдёт время следующего повторения.'
                                : '$index ответов сохранено.\nСлова с ответом «Снова» вернутся через минуту.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(height: 1.7),
                          ),
                          const SizedBox(height: 28),
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Отлично'),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              Text(
                                'КАРТОЧКА ${index + 1} ИЗ ${cards.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text('${c.today}/${c.goal} сегодня'),
                            ],
                          ),
                          const SizedBox(height: 14),
                          LinearProgressIndicator(
                            value: index / cards.length,
                            minHeight: 5,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 32),
                          Semantics(
                            button: !revealed,
                            label: revealed
                                ? 'Перевод открыт'
                                : 'Нажмите, чтобы открыть перевод',
                            child: GestureDetector(
                              onTap: revealed
                                  ? null
                                  : () => setState(() => revealed = true),
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 220),
                                child: Glass(
                                  opaque: c.reduceGlass,
                                  color: scheme.primaryContainer.withValues(
                                    alpha: .25,
                                  ),
                                  padding: const EdgeInsets.all(30),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Chip(
                                            label: Text(cards[index].level),
                                            side: BorderSide.none,
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            tooltip: 'Произнести слово',
                                            onPressed: () =>
                                                c.speak(cards[index].word),
                                            icon: const Icon(
                                              Icons.volume_up_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        cards[index].word,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -1,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        cards[index].phonetic,
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      if (revealed) ...[
                                        const Divider(),
                                        const SizedBox(height: 24),
                                        Text(
                                          cards[index].translation,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineSmall,
                                        ),
                                        const SizedBox(height: 18),
                                        Text(
                                          cards[index].example,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            height: 1.6,
                                            color: scheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ] else
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 25,
                                          ),
                                          child: Text(
                                            'Вспомните значение слова',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (!revealed)
                            FilledButton(
                              onPressed: () => setState(() => revealed = true),
                              child: const Text('Показать перевод'),
                            )
                          else ...[
                            const Text(
                              'Насколько легко вспомнилось?',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, size) => Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final recall in Recall.values)
                                    SizedBox(
                                      width: (size.maxWidth - 10) / 2,
                                      child: OutlinedButton(
                                        onPressed: busy
                                            ? null
                                            : () => answer(recall),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.all(18),
                                          side: BorderSide(
                                            color: scheme.outlineVariant,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              [
                                                'Снова',
                                                'Трудно',
                                                'Помню',
                                                'Легко',
                                              ][recall.index],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              _interval(recall),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            'Прогресс сохраняется после каждого ответа',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _interval(Recall recall) {
    if (recall == Recall.again) return 'через 1 минуту';
    final next = widget.controller.scheduler.review(
      widget.controller.progress[cards[index].id],
      recall,
      DateTime.now(),
    );
    return 'через ${next.interval} дн.';
  }
}
