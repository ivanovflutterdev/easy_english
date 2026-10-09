import '../domain/services.dart';
import 'package:flutter/material.dart';
import '../application/learning_controller.dart';
import 'app.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});
  final LearningController controller;
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          'Ваш английский. Ваши правила.',
          subtitle: 'Сделайте обучение удобным именно для вас.',
        ),
        Glass(
          opaque: c.reduceGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.user?.email ?? 'Учитесь без регистрации',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.syncStatus,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (c.auth == null)
                const Text(
                  'Локальный режим. Для входа, восстановления пароля и синхронизации нужно подключить Firebase.',
                  style: TextStyle(height: 1.5),
                )
              else if (c.user == null) ...[
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => AuthDialog(controller: c),
                  ),
                  icon: const Icon(Icons.cloud_outlined),
                  label: const Text('Войти или создать аккаунт'),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Гостевой прогресс хранится отдельно от аккаунта.',
                  style: TextStyle(fontSize: 12),
                ),
              ] else
                TextButton(
                  onPressed: () async {
                    try {
                      await c.signOut();
                    } catch (_) {
                      c.report('Не удалось выйти. Попробуйте ещё раз.');
                    }
                  },
                  child: const Text('Выйти из аккаунта'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Glass(
          opaque: c.reduceGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ритм обучения',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 22),
              Text('Дневная цель: ${c.goal} ответов'),
              Slider(
                value: c.goal.toDouble(),
                min: 5,
                max: 50,
                divisions: 9,
                label: '${c.goal}',
                onChanged: (v) => c.setting('goal', v.round()),
              ),
              const SizedBox(height: 12),
              const Text('Произношение'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  for (final accent in [
                    ('en-GB', 'Британское'),
                    ('en-US', 'Американское'),
                  ])
                    ChoiceChip(
                      label: Text(accent.$2),
                      selected: c.accent == accent.$1,
                      onSelected: (_) => c.setting('accent', accent.$1),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('Скорость озвучки'),
              Slider(
                value: c.speechRate,
                min: .25,
                max: .65,
                divisions: 8,
                onChanged: (v) => c.setting('rate', v),
              ),
              TextButton.icon(
                onPressed: () => c.speak('A little progress every day.'),
                icon: const Icon(Icons.volume_up_outlined),
                label: const Text('Послушать пример'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Glass(
          opaque: c.reduceGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Внешний вид',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: [
                  for (final mode in ThemeMode.values)
                    ChoiceChip(
                      label: Text(
                        ['Как в системе', 'Светлая', 'Тёмная'][mode.index],
                      ),
                      selected: c.themeMode == mode,
                      onSelected: (_) => c.setting('theme', mode.index),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              const Text('Цвет акцента'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: [
                  for (var i = 0; i < accents.length; i++)
                    IconButton.filled(
                      onPressed: () => c.setting('color', i),
                      style: IconButton.styleFrom(backgroundColor: accents[i]),
                      tooltip: const [
                        'Салатовый',
                        'Травяной',
                        'Мятный',
                        'Небесный',
                        'Лавандовый',
                        'Янтарный',
                        'Коралловый',
                        'Розовый',
                      ][i],
                      icon: Icon(
                        c.colorIndex == i ? Icons.check : Icons.circle,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Размер текста: ${(c.textScale * 100).round()}%'),
              Slider(
                value: c.textScale,
                min: .9,
                max: 1.3,
                divisions: 4,
                onChanged: (v) => c.setting('textScale', v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Уменьшить прозрачность'),
                subtitle: const Text('Более контрастные панели'),
                value: c.reduceGlass,
                onChanged: (v) => c.setting('reduceGlass', v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Glass(
          opaque: c.reduceGlass,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Мягкие напоминания',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Каждый день'),
                subtitle: const Text('Работает даже без интернета'),
                value: c.reminderEnabled,
                onChanged: (v) => c.setReminder(v),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(
                  'В ${c.reminderHour.toString().padLeft(2, '0')}:${c.reminderMinute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: c.reminderHour,
                      minute: c.reminderMinute,
                    ),
                  );
                  if (time != null) {
                    if (c.reminderEnabled) {
                      await c.setReminder(true, time: time);
                    } else {
                      await c.setting('hour', time.hour);
                      await c.setting('minute', time.minute);
                    }
                  }
                },
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Push о повторении'),
                subtitle: const Text('Когда пора повторить изученные слова'),
                value: c.pushEnabled,
                onChanged: c.user == null ? null : (v) => c.setPush(v),
              ),
              const Divider(),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.widgets_outlined),
                title: Text('Прогресс на главном экране'),
                subtitle: Text(
                  'Добавьте виджет Easy English через меню виджетов вашего устройства.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Center(
          child: Text(
            'Easy English · По одному слову к новому миру',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key, required this.controller});
  final LearningController controller;
  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final email = TextEditingController(), password = TextEditingController();
  bool register = false, busy = false;
  String? message;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit({bool reset = false}) async {
    final address = email.text.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(address)) {
      setState(() => message = 'Введите корректный email.');
      return;
    }
    if (!reset && password.text.length < 6) {
      setState(() => message = 'Пароль должен содержать минимум 6 символов.');
      return;
    }
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final auth = widget.controller.auth!;
      if (reset) {
        await auth.sendPasswordResetEmail(email: address);
        if (mounted) {
          setState(
            () => message =
                'Если аккаунт существует, письмо для восстановления отправлено. Проверьте также папку «Спам».',
          );
        }
      } else {
        if (register) {
          await auth.createUserWithEmailAndPassword(
            email: address,
            password: password.text,
          );
        } else {
          await auth.signInWithEmailAndPassword(
            email: address,
            password: password.text,
          );
        }
        if (mounted) Navigator.pop(context);
      }
    } on AuthFailure catch (e) {
      final text = switch (e.code) {
        'email-already-in-use' =>
          'Этот email уже зарегистрирован. Попробуйте войти.',
        'weak-password' => 'Выберите более надёжный пароль.',
        'network-request-failed' => 'Нет связи с сервером. Проверьте интернет.',
        'too-many-requests' => 'Слишком много попыток. Попробуйте позже.',
        'operation-not-allowed' => 'В Firebase ещё не включён вход по email.',
        _ => 'Не удалось войти. Проверьте email и пароль.',
      };
      if (mounted) setState(() => message = text);
    } catch (_) {
      if (mounted) {
        setState(
          () => message = 'Сервис временно недоступен. Попробуйте позже.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(register ? 'Начните свою историю' : 'С возвращением!'),
    content: SizedBox(
      width: 380,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Ваши слова и прогресс — на всех устройствах.'),
            const SizedBox(height: 22),
            TextField(
              controller: email,
              enabled: !busy,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: password,
              enabled: !busy,
              obscureText: true,
              autofillHints: [
                register ? AutofillHints.newPassword : AutofillHints.password,
              ],
              decoration: const InputDecoration(labelText: 'Пароль'),
            ),
            const SizedBox(height: 12),
            if (message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  message!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            FilledButton(
              onPressed: busy ? null : submit,
              child: Text(
                busy
                    ? 'Подождите…'
                    : register
                    ? 'Создать аккаунт'
                    : 'Войти',
              ),
            ),
            TextButton(
              onPressed: busy ? null : () => submit(reset: true),
              child: const Text('Забыли пароль?'),
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () => setState(() {
                      register = !register;
                      message = null;
                    }),
              child: Text(
                register ? 'Уже есть аккаунт? Войти' : 'Создать новый аккаунт',
              ),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: busy ? null : () => Navigator.pop(context),
        child: const Text('Позже'),
      ),
    ],
  );
}
