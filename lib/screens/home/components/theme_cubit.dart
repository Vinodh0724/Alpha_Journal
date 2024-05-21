// theme_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTheme { light, dark }

class ThemeCubit extends Cubit<AppTheme> {
  ThemeCubit() : super(AppTheme.light);

  void toggleTheme() {
    state == AppTheme.light ? emit(AppTheme.dark) : emit(AppTheme.light);
  }
}
