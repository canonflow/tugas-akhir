import 'package:get_it/get_it.dart';
import 'package:frontend/features/auth/services/auth_service.dart';
import 'package:frontend/features/dosen/services/topic_service.dart';

final getIt = GetIt.instance;

void setupAllServices() {
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<TopicService>(() => TopicService());
}