import 'package:assigned_task_quantek/screens/ticket_list_screen.dart';
import 'package:assigned_task_quantek/services/ticket_api_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SupportTicketApp());
}

class SupportTicketApp extends StatelessWidget {
  const SupportTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Support Ticket Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006B5C)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(isDense: true),
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      home: TicketListScreen(apiService: TicketApiService()),
    );
  }
}
