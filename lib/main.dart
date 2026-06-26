import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart'; 
import 'pages/auth/login_page.dart';
import 'pages/dashboard/dashboard_page.dart';
import 'pages/auth/change_password_page.dart';
import 'pages/vaccination/vaccination_form_page.dart';
import 'pages/vaccination/vaccination_details_page.dart';
import 'pages/managment/sector_management_page.dart';
import 'pages/managment/user_management_page.dart';
import 'pages/auth/recovery_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campaña Vacunación',
      // Ruta inicial: login si no hay usuario autenticado
      initialRoute: Supabase.instance.client.auth.currentUser == null ? '/login' : '/dashboard',
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/change-password': (context) => const ChangePasswordPage(),
        '/vaccination-form': (context) => const VaccinationFormPage(),
        '/vaccination-details': (context) => const VaccinationDetailsPage(),
        '/sector-management': (context) => const SectorManagementPage(),
        '/recovery-password': (context) => const RecoveryPasswordPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/user-management') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => UserManagementPage(
              currentRole: args['currentRole'],
              sectorId: args['sectorId'],
            ),
          );
        }
        return null;
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}
