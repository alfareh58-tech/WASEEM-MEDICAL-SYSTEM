import 'package:flutter/material.dart';

import 'sessions_screen.dart';
import 'departments_screen.dart';
import 'staff_screen.dart';
import 'finance_screen.dart';
import 'messages_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المزيد'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _item(
            context,
            'الجلسات والباقات',
            Icons.healing,
            const SessionsScreen(),
          ),

          _item(
            context,
            'الأقسام والخدمات',
            Icons.local_hospital,
            const DepartmentsScreen(),
          ),

          _item(
            context,
            'الكادر والعمال',
            Icons.groups,
            const StaffScreen(),
          ),

          _item(
            context,
            'الإدارة المالية',
            Icons.account_balance_wallet,
            const FinanceScreen(),
          ),

          // مركز الرسائل
          _item(
            context,
            'مركز الرسائل',
            Icons.message,
            const MessagesScreen(),
          ),

          _item(
            context,
            'التقارير',
            Icons.bar_chart,
            const ReportsScreen(),
          ),

          _item(
            context,
            'الإعدادات',
            Icons.settings,
            const SettingsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_left),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}
