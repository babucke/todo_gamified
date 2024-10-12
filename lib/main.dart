// lib/main.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'blocs/authentication/authentication_bloc.dart';
import 'blocs/authentication/authentication_state.dart';
import 'blocs/family/family_bloc.dart';
import 'blocs/family/family_state.dart';
import 'localization.dart';
import 'repositories/authentication_repository.dart';
import 'repositories/family_repository.dart';
import 'ui/screens/family/create_family_screen.dart';
import 'ui/screens/family/family_selection_screen.dart';
import 'ui/screens/family/join_family_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/select_role_screen.dart';
import 'ui/screens/signup_screen.dart';
import 'ui/screens/verify_email_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    RepositoryProvider(
      create: (context) => AuthenticationRepository(),
      child: RepositoryProvider(
        create: (context) => FamilyRepository(),
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  // Definiere einen GlobalKey für den Navigator
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final authenticationRepository = RepositoryProvider.of<AuthenticationRepository>(context);
    final familyRepository = RepositoryProvider.of<FamilyRepository>(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthenticationBloc(authenticationRepository: authenticationRepository),
        ),
        BlocProvider(
          create: (context) => FamilyBloc(familyRepository: familyRepository),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey, // Weisen Sie den NavigatorKey zu
        title: 'Deine App',
        // Fügen Sie die lokalen unterstützten Sprachen hinzu
        supportedLocales: [
          Locale('en'), // Englisch
          Locale('de'), // Deutsch
        ],
        // Lokalisierung Delegates
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return supportedLocales.first;
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignUpScreen(),
          '/home': (context) => HomeScreen(),
          '/selectRole': (context) => SelectRoleScreen(),
          '/verifyEmail': (context) => VerifyEmailScreen(),
          '/familySelection': (context) => FamilySelectionScreen(),
          '/joinFamily': (context) => JoinFamilyScreen(),
          '/createFamily': (context) => CreateFamilyScreen(),
        },
        builder: (context, child) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  print('Aktueller AuthenticationState: $state');

                  if (state is AuthenticationAuthenticated) {
                    FirebaseFirestore.instance.collection('users').doc(state.user.uid).get().then((userDoc) {
                      if (userDoc.exists && (userDoc.data()!['familyId'] == null || userDoc.data()!['familyId'] == '')) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _navigatorKey.currentState?.pushReplacementNamed('/familySelection');
                        });
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _navigatorKey.currentState?.pushReplacementNamed('/home');
                        });
                      }
                    });
                  } else if (state is AuthenticationNeedsRole) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _navigatorKey.currentState?.pushReplacementNamed('/selectRole');
                    });
                  } else if (state is AuthenticationNeedsVerification) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _navigatorKey.currentState?.pushReplacementNamed('/verifyEmail');
                    });
                  } else if (state is AuthenticationError) {
                    ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
              ),
              BlocListener<FamilyBloc, FamilyState>(
                listener: (context, state) {
                  if (state is FamilyJoinSuccess || state is FamilyCreateSuccess) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // Verwenden Sie pushAndRemoveUntil, um den Navigationsstapel zu bereinigen
                      _navigatorKey.currentState?.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                            (Route<dynamic> route) => false,
                      );
                      ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
                        SnackBar(content: Text('Familie erfolgreich beigetreten/gründet!')),
                      );
                    });
                  } else if (state is FamilyJoinFailure || state is FamilyCreateFailure) {
                    ScaffoldMessenger.of(_navigatorKey.currentContext!).showSnackBar(
                      SnackBar(content: Text('state.error')),
                    );
                  }
                },
              ),
            ],
            child: child!,
          );
        },
      ),
    );
  }
}
