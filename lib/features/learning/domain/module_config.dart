class ModuleConfig {
  const ModuleConfig({
    required this.title,
    required this.routeName,
    required this.jsonPath,
    this.isImageQuestion = false,
  });

  final String title;
  final String routeName;
  final String jsonPath;
  final bool isImageQuestion;

  String get imageBasePath => 'driving_rules_data/driving_rules_data/sign/';

  static const general = ModuleConfig(
    title: 'General',
    routeName: '/module/general',
    jsonPath: 'driving_rules_data/driving_rules_data/general.json',
  );

  static const emergency = ModuleConfig(
    title: 'Emergency',
    routeName: '/module/emergency',
    jsonPath: 'driving_rules_data/driving_rules_data/emergency.json',
  );

  static const technique = ModuleConfig(
    title: 'Technique',
    routeName: '/module/technique',
    jsonPath: 'driving_rules_data/driving_rules_data/technique.json',
  );

  static const sign = ModuleConfig(
    title: 'Sign',
    routeName: '/module/sign',
    jsonPath: 'driving_rules_data/driving_rules_data/sign.json',
    isImageQuestion: true,
  );

  static const priority = ModuleConfig(
    title: 'Priority',
    routeName: '/module/priority',
    jsonPath: 'driving_rules_data/driving_rules_data/priority.json',
    isImageQuestion: true,
  );

  static const all = <ModuleConfig>[
    general,
    emergency,
    technique,
    sign,
    priority,
  ];
}
