import 'dart:ui';
import 'package:flutter/material.dart';
import '../application/learning_controller.dart';
import 'screens.dart';
import 'localization.dart';

const accents = [
  Color(0xFF9BCB3B), // Салатовый
  Color(0xFF70B82D), // Травяной
  Color(0xFF00A896), // Мятный
  Color(0xFF38BDF8), // Небесный
  Color(0xFF7C4DFF), // Лавандовый
  Color(0xFFFFB020), // Янтарный
  Color(0xFFFF6B4A), // Коралловый
  Color(0xFFE83E8C), // Розовый
];

class EasyEnglishApp extends StatelessWidget {
  const EasyEnglishApp({super.key, required this.controller});
  final LearningController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      ThemeData theme(Brightness brightness) {
        final dark = brightness == Brightness.dark;
        final scheme = ColorScheme.fromSeed(
          seedColor:
              accents[controller.colorIndex.clamp(0, accents.length - 1)],
          brightness: brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        );
        return ThemeData(
          useMaterial3: true,
          colorScheme: scheme,
          brightness: brightness,
          scaffoldBackgroundColor: Colors.transparent,
          fontFamily: 'sans-serif',
          textTheme: Typography.material2021(platform: TargetPlatform.iOS).black
              .apply(
                bodyColor: dark
                    ? const Color(0xFFF1F0FA)
                    : const Color(0xFF292744),
                displayColor: dark
                    ? const Color(0xFFF1F0FA)
                    : const Color(0xFF292744),
              ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: dark
                ? const Color(0xFF262044)
                : Colors.white.withValues(alpha: .88),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          navigationBarTheme: const NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          dividerTheme: DividerThemeData(
            color: scheme.outlineVariant.withValues(alpha: .4),
          ),
        );
      }

      return MaterialApp(
        title: 'Easy English',
        locale: controller.locale,
        debugShowCheckedModeBanner: false,
        theme: theme(Brightness.light),
        darkTheme: theme(Brightness.dark),
        themeMode: controller.themeMode,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.textScalerOf(context).scale(controller.textScale),
            ),
          ),
          child: child!,
        ),
        home: HomeShell(controller: controller),
      );
    },
  );
}

class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color,
    this.opaque = false,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool opaque;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color:
            color ??
            (dark ? const Color(0xFF23243E) : Colors.white).withValues(
              alpha: opaque ? 1 : .68,
            ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: dark ? .09 : .8),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF625799).withValues(alpha: dark ? .03 : .045),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: opaque
          ? panel
          : BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: panel,
            ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});
  final LearningController controller;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selected = 0;
  static const labels = [
    'Обучение',
    'Словарь',
    'Прогресс',
    'Достижения',
    'Настройки',
  ];
  static const icons = [
    Icons.space_dashboard_rounded,
    Icons.style_outlined,
    Icons.bar_chart_rounded,
    Icons.emoji_events_outlined,
    Icons.tune_rounded,
  ];
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listen);
  }

  void _listen() {
    final error = widget.controller.error;
    if (error == null) return;
    widget.controller.clearError();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listen);
    super.dispose();
  }

  void study([String deck = 'all']) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StudyScreen(controller: widget.controller, deck: deck),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [
                  const Color(0xFF151526),
                  const Color(0xFF1C2037),
                  const Color(0xFF142A30),
                ]
              : [
                  Color.lerp(
                    Colors.white,
                    accents[c.colorIndex.clamp(0, accents.length - 1)],
                    .16,
                  )!,
                  Color.lerp(
                    Colors.white,
                    accents[c.colorIndex.clamp(0, accents.length - 1)],
                    .08,
                  )!,
                  const Color(0xFFFFF7C7),
                  Color.lerp(
                    Colors.white,
                    accents[c.colorIndex.clamp(0, accents.length - 1)],
                    .11,
                  )!,
                ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;
          final screen = switch (selected) {
            0 => Dashboard(
              controller: c,
              onStudy: study,
              onLibrary: () => setState(() => selected = 1),
            ),
            1 => LibraryScreen(controller: c, onStudy: study),
            2 => ProgressScreen(controller: c),
            3 => AchievementsScreen(controller: c),
            _ => SettingsScreen(controller: c),
          };
          return Scaffold(
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: 220,
                        child: Glass(
                          opaque: c.reduceGlass,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 8,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Brand(),
                                ),
                              ),
                              const SizedBox(height: 30),
                              for (var i = 0; i < labels.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    selected: selected == i,
                                    selectedTileColor: Theme.of(
                                      context,
                                    ).colorScheme.primary.withValues(alpha: .1),
                                    leading: Icon(icons[i]),
                                    title: Text(
                                      labels[i],
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    onTap: () => setState(() => selected = i),
                                  ),
                                ),
                              const Spacer(),
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF8C7DDD),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Маленькие шаги.\nБольшие возможности.',
                                style: TextStyle(
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                c.syncStatus,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: !c.ready
                        ? const Center(child: CircularProgressIndicator())
                        : Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1250),
                              child: SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(
                                  wide ? 20 : 20,
                                  26,
                                  wide ? 40 : 20,
                                  32,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if (!wide)
                                          const Expanded(
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Brand(),
                                              ),
                                            ),
                                          )
                                        else
                                          Text(
                                            EasyLocalizations.nav[selected].of(
                                              context,
                                            ),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                        if (wide) const Spacer(),
                                        Tooltip(
                                          message: 'Серия ежедневных занятий',
                                          child: Chip(
                                            avatar: const Icon(
                                              Icons
                                                  .local_fire_department_rounded,
                                              size: 20,
                                              color: Color(0xFFDF8751),
                                            ),
                                            label: Text('${c.streak} дн.'),
                                            side: BorderSide.none,
                                            color: WidgetStatePropertyAll(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .surface
                                                  .withValues(alpha: .6),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          onPressed: () => c.setting(
                                            'language',
                                            c.locale.languageCode == 'uk'
                                                ? 'ru'
                                                : 'uk',
                                          ),
                                          icon: Text(
                                            c.locale.languageCode == 'uk'
                                                ? 'UA'
                                                : 'RU',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          tooltip: EasyLocalizations.language
                                              .of(context),
                                        ),
                                        IconButton.filledTonal(
                                          onPressed: () =>
                                              setState(() => selected = 4),
                                          icon: const Icon(
                                            Icons.person_outline_rounded,
                                          ),
                                          tooltip: 'Аккаунт',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 32),
                                    screen,
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: wide
                ? null
                : Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: .86),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: .2),
                        ),
                      ),
                    ),
                    child: NavigationBar(
                      selectedIndex: selected,
                      onDestinationSelected: (i) =>
                          setState(() => selected = i),
                      destinations: [
                        for (var i = 0; i < labels.length; i++)
                          NavigationDestination(
                            icon: Icon(icons[i]),
                            label: EasyLocalizations.nav[i].of(context),
                          ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 37,
        height: 37,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.layers_rounded, color: Colors.white, size: 23),
      ),
      const SizedBox(width: 10),
      const Text(
        'easy',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 23,
          letterSpacing: -.8,
        ),
      ),
      Text(
        'english',
        style: TextStyle(
          fontSize: 23,
          letterSpacing: -.8,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ],
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.7,
                ),
              ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}
