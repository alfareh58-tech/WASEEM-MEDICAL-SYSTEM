import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/messaging_service.dart';
import '../services/settings_service.dart';
import '../services/pdf_service.dart';

class PatientDetailsScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Map<String, Object?>? patientData;

  bool loading = true;
  bool sendingMessage = false;
  bool printing = false;

  @override
  void initState() {
    super.initState();
    loadPatient();
  }

  Future<void> loadPatient() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final result = await DatabaseService.instance.patient(
        widget.patientId,
      );

      if (!mounted) return;

      setState(() {
        patientData = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحميل ملف المريض: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String value(String key) {
    final result = patientData?[key]?.toString().trim() ?? '';
    return result;
  }

  String displayValue(String key) {
    final result = value(key);
    return result.isEmpty ? 'غير محدد' : result;
  }

  Future<void> sendWhatsApp() async {
    if (patientData == null) return;

    final phone = value('phone');

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد رقم جوال مسجل لهذا المريض.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      sendingMessage = true;
    });

    try {
      final center = await SettingsService.instance.centerName();
      final support = await SettingsService.instance.supportPhone();

      final message = MessagingService.registrationMessage(
        patient: value('full_name'),
        fileNo: value('file_no'),
        center: center,
        service: value('service').isEmpty
            ? value('department')
            : value('service'),
        date: _formatRegistrationDate(value('created_at')),
        support: support,
        gender: value('gender'),
      );

      final opened = await MessagingService.whatsapp(
        phone,
        message,
      );

      if (!mounted) return;

      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر فتح WhatsApp. تأكد من تثبيت التطبيق أو صحة رقم الجوال.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تجهيز الرسالة: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sendingMessage = false;
        });
      }
    }
  }

  Future<void> printPatient() async {
    if (patientData == null) return;

    setState(() {
      printing = true;
    });

    try {
      final center = await SettingsService.instance.centerName();

      await PdfService.printPatientCard(
        patientData!,
        center,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذرت الطباعة: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          printing = false;
        });
      }
    }
  }

  String _formatRegistrationDate(String raw) {
    if (raw.trim().isEmpty) {
      return 'غير محدد';
    }

    try {
      final date = DateTime.parse(raw);

      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();

      return '$year/$month/$day';
    } catch (_) {
      return raw.length >= 10 ? raw.substring(0, 10) : raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (patientData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ملف المريض'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 70,
                ),
                const SizedBox(height: 16),
                const Text(
                  'لم يتم العثور على ملف المريض.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: loadPatient,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          value('full_name').isEmpty
              ? 'ملف المريض'
              : value('full_name'),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: loading ? null : loadPatient,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadPatient,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          children: [
            _patientHeader(),
            const SizedBox(height: 14),
            _basicInformation(),
            const SizedBox(height: 14),
            _medicalInformation(),
            const SizedBox(height: 14),
            _actionsCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _patientHeader() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 34,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayValue('full_name'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'رقم الملف: ${displayValue('file_no')}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basicInformation() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle(
              'البيانات الأساسية',
              Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _info('الاسم الكامل', 'full_name'),
            _info('رقم الملف', 'file_no'),
            _info('رقم الهاتف', 'phone'),
            _info('رقم الهوية', 'national_id'),
            _info('الجنس', 'gender'),
            _info('العمر', 'age'),
            _info('تاريخ الميلاد', 'birth_date'),
            _info('العنوان', 'address'),
          ],
        ),
      ),
    );
  }

  Widget _medicalInformation() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle(
              'المعلومات الطبية والإدارية',
              Icons.medical_information_outlined,
            ),
            const SizedBox(height: 12),
            _info('القسم', 'department'),
            _info('الخدمة', 'service'),
            _info('الطبيب / الأخصائي', 'doctor'),
            _info('مصدر المعرفة', 'referral_source'),
            _info('حالة الملف', 'status'),
            _info(
              'تاريخ التسجيل',
              'created_at',
              customValue: _formatRegistrationDate(
                value('created_at'),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'الملاحظات',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: Text(
                displayValue('notes'),
                textDirection: TextDirection.rtl,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionsCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle(
              'إجراءات الملف',
              Icons.settings_outlined,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: sendingMessage ? null : sendWhatsApp,
                  icon: sendingMessage
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.chat),
                  label: const Text('إرسال عبر WhatsApp'),
                ),
                OutlinedButton.icon(
                  onPressed: printing ? null : printPatient,
                  icon: printing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.print),
                  label: const Text('طباعة بطاقة المريض'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _info(
    String title,
    String key, {
    String? customValue,
  }) {
    final text = customValue ?? displayValue(key);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
