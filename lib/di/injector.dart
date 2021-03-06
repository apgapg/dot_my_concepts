import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fa_flutter_core/fa_flutter_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_record_lesson/app/bloc/app_bloc_impl.dart';
import 'package:flutter_record_lesson/app/bloc/base/app_bloc.dart';
import 'package:flutter_record_lesson/data/local/app_db.dart';
import 'package:flutter_record_lesson/data/local/sembast_app_db.dart';
import 'package:flutter_record_lesson/data/repo/google_login_repository.dart';
import 'package:flutter_record_lesson/modules/common/src/bloc/record_lesson_bloc.dart';
import 'package:flutter_record_lesson/modules/profile/index.dart';
import 'package:flutter_record_lesson/utils/log_utils.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ignore_for_file: cascade_invocations
GetIt injector = GetIt.instance;

enum Flavor {
  debug,
}

class Injector {
  factory Injector() => _singleton;

  Injector._internal();

  static final Injector _singleton = Injector._internal();

  Future<void> configure(Flavor flavor) async {
    try {
      if (isMobile) {
        await Firebase.initializeApp();
      }
      await _initHelpers();
      await _initBlocs();
    } catch (e, s) {
      logger.e(e, s);
      rethrow;
    }
  }

  Future<void> _initHelpers() async {
    //await Executor().warmUp();

    injector.registerSingleton<AppLog>(
      logger,
    );

/*    // NetworkInfo
    injector.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(DataConnectionChecker()),
    );*/

    /// SharedPreferences
    final appsPrefs =
        isMobile ? SharedAppPrefs() : JsonAppPrefs(name: 'app_prefs');
    await appsPrefs.initialise();
    injector.registerSingleton<AppPrefs>(appsPrefs);
    //final appPrefsHelper = AppPrefsHelperImpl(appPrefs: injector());
    //injector.registerSingleton<AppPrefsHelper>(appPrefsHelper);

    // FirestoreInstance
    injector.registerLazySingleton<FirebaseFirestore>(
        () => FirebaseFirestore.instance);

    // GoogleLoginRepository
    injector.registerLazySingleton<GoogleLoginRepository>(
      () => GoogleLoginRepository(
        googleSignIn: GoogleSignIn(),
      ),
    );

    // UserRepository
    final repo = FirebaseUserRepository(
      prefHelper: injector(),
      firestore: injector(),
    );
    await repo.init();
    injector.registerLazySingleton<UserRepository>(() => repo);

    /// DbHelper;
    final appDb = SembastAppDb();
    await appDb.initialise();
    injector.registerSingleton<AppDb>(appDb);
  }

  Future<void> _initBlocs() async {
    // ApplicationBloc
    final appBloc = AppBlocImpl(
      appPrefs: injector(),
      firestore: injector(),
    );
    //await appBloc.init();
    injector.registerSingleton<AppBloc>(
      appBloc,
    );

    // GoogleLoginRepository
    injector.registerLazySingleton<RecordLessonBloc>(
      () => RecordLessonBloc(),
    );
  }
}
