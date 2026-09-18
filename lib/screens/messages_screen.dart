import 'package:flutter/material.dart';
import '../services/messaging_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessageTemplate {
  final String id;
  final String title;
  final IconData icon;
  final String description;
  final String defaultText;

  const _MessageTemplate({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.defaultText,
  });
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<_MessageTemplate> _templates = const [
    _MessageTemplate(
      id: 'registration',
      title: 'تسجيل مريض جديد',
      icon: Icons.person_add_alt_1,
      description: 'رسالة تأكيد تسجيل المريض وفتح الملف الطبي.',
      defaultText:
          '''السلام عليكم ورحمة الله وبركاته

{المخاطبة}،

نرحب بكم في {المركز}، ونفيدكم بأنه تم تسجيل بياناتكم بنجاح.

رقم الملف الطبي: {رقم الملف}
الخدمة: {الخدمة}
تاريخ التسجيل: {التاريخ}

نشكركم على ثقتكم بنا، ونتمنى لكم دوام الصحة والعافية.

{المركز}
{التواصل}''',
    ),
    _MessageTemplate(
      id: 'appointment',
      title: 'تذكير بالموعد',
      icon: Icons.event_available,
      description: 'رسالة تذكير بموعد المريض.',
      defaultText:
          '''السلام عليكم ورحمة الله وبركاته

{المخاطبة}،

نذكّركم بموعدكم لدى {المركز}.

التاريخ: {التاريخ}
الوقت: {الوقت}
الطبيب / الأخصائي: {الطبيب}

نرجو الالتزام بالموعد المحدد والحضور في الوقت المناسب.

مع تمنياتنا لكم بالصحة والعافية.

{المركز}
{التواصل}''',
    ),
    _MessageTemplate(
      id: 'receipt',
      title: 'سند قبض',
      icon: Icons.receipt_long,
      description: 'إشعار للمريض بتسجيل سند قبض مالي.',
      defaultText:
          '''السلام عليكم ورحمة الله وبركاته

{المخاطبة}،

نفيدكم بأنه تم تسجيل سند القبض الخاص بكم لدى {المركز} بنجاح.

رقم السند: {رقم السند}
المبلغ: {المبلغ}
البيان: {البيان}
التاريخ: {التاريخ}

تم حفظ العملية في السجل المالي.

شكرًا لتعاملكم معنا، ونتمنى لكم دوام الصحة والعافية.

{المركز}
{التواصل}''',
    ),
    _MessageTemplate(
      id: 'session',
      title: 'تسجيل جلسة',
      icon: Icons.medical_services,
      description: 'إشعار بتسجيل جلسة وتحديث رصيد الباقة.',
      defaultText:
          '''السلام عليكم ورحمة الله وبركاته

{المخاطبة}،

نفيدكم بأنه تم تسجيل جلسة علاجية لكم لدى {المركز}.

اسم الباقة: {الباقة}
الجلسات المستخدمة: {الجلسات المستخدمة}
الجلسات المتبقية: {الجلسات المتبقية}
التاريخ: {التاريخ}

تم تحديث رصيد الجلسات في ملفكم الطبي.

مع تمنياتنا لكم بدوام الصحة والعافية.

{المركز}''',
    ),
    _MessageTemplate(
      id: 'package_low',
      title: 'قرب انتهاء الباقة',
      icon: Icons.warning_amber_rounded,
      description: 'تنبيه عند انخفاض الجلسات المتبقية.',
      defaultText:
          '''السلام عليكم ورحمة الله وبركاته

{المخاطبة}،

نود تنبيهكم إلى انخفاض عدد الجلسات المتبقية في باقتكم لدى {المركز}.

اسم الباقة: {الباقة}
الجلسات المتبقية: {الجلسات المتبقية}
التاريخ: {التاريخ}

يمكنكم التواصل مع المركز عند الحاجة إلى تجديد الباقة.

مع تمنياتنا لكم بدوام الصحة والعافية.

{المركز}
{التواصل}''',
    ),
    _MessageTemplate(
      id: 'package_finished',
      title: 'انتهاء الباقة',
      icon: Icons.assignment_late_outlined,
      description: 'إشعار بانتهاء جميع جلسات الباقة.',
      defaultText:
          '''السلام عليكم ورحمة الله وبركاته

{المخاطبة}،

نفيدكم بأن جميع جلسات باقة العلاج الخاصة بكم لدى {المركز} قد تم استخدامها.

اسم الباقة: {الباقة}
الجلسات المتبقية: 0
التاريخ: {التاريخ}

للاستفسار عن الباقات المتاحة أو التجديد، يرجى التواصل مع المركز.

مع تمنياتنا لكم بدوام الصحة والعافية.

{المركز}
{التواصل}''',
    ),
    _MessageTemplate(
      id: 'expense',
      title: 'سند صرف',
      icon: Icons.money_off,
      description: 'إشعار بتسجيل سند صرف مالي.',
      defaultText:
          '''السلام عليكم ورحمة الله وبركاته

إشعار سند صرف مالي

تم تسجيل سند الصرف التالي لدى {المركز} بنجاح.

المستفيد: {المستفيد}
رقم السند: {رقم السند}
المبلغ: {المبلغ}
الحساب: {الحساب}
البيان: {البيان}
التاريخ: {التاريخ}

{المركز}''',
    ),
  ];

  late Map<String, String> _texts;

  @override
  void initState() {
    super.initState();

    _texts = {
      for (final template in _templates)
        template.id: template.defaultText,
    };
  }

  String _preview(String text) {
    return text
        .replaceAll('{المخاطبة}', 'الأخ محمد أحمد')
        .replaceAll('{اسم المريض}', 'محمد أحمد')
        .replaceAll('{المركز}', 'نظام وسيم الطبي PRO')
        .replaceAll('{رقم الملف}', 'MED-00001')
        .replaceAll('{الخدمة}', 'العلاج الطبيعي')
        .replaceAll('{التاريخ}', '19/09/2026')
        .replaceAll('{الوقت}', '05:00 مساءً')
        .replaceAll('{الطبيب}', 'الأخصائي')
        .replaceAll('{التواصل}', 'للتواصل والاستفسار: 777000000')
        .replaceAll('{رقم السند}', 'RV-00001')
        .replaceAll('{المبلغ}', '10,000 ريال')
        .replaceAll('{البيان}', 'رسوم جلسة علاجية')
        .replaceAll('{الباقة}', 'الباقة العلاجية الأولى')
        .replaceAll('{الجلسات المستخدمة}', '3')
        .replaceAll('{الجلسات المتبقية}', '7')
        .replaceAll('{المستفيد}', 'محمد أحمد')
        .replaceAll('{الحساب}', 'المصروفات العمومية');
  }

  Future<void> _editTemplate(_MessageTemplate template) async {
    final controller = TextEditingController(
      text: _texts[template.id] ?? template.defaultText,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(template.icon),
              const SizedBox(width: 10),
              Expanded(child: Text('تعديل: ${template.title}')),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'يمكنك إعادة صياغة الرسالة كما تريد.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 18,
                    textDirection: TextDirection.rtl,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'نص الرسالة',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'المتغيرات المتاحة:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '{اسم المريض}  {المخاطبة}  {المركز}  {رقم الملف}\n'
                    '{الخدمة}  {التاريخ}  {الوقت}  {الطبيب}\n'
                    '{رقم السند}  {المبلغ}  {البيان}\n'
                    '{الباقة}  {الجلسات المستخدمة}  {الجلسات المتبقية}\n'
                    '{المستفيد}  {الحساب}  {التواصل}',
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              icon: const Icon(Icons.save),
              label: const Text('حفظ القالب'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result != null && result.trim().isNotEmpty) {
      setState(() {
        _texts[template.id] = result.trim();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ تعديل القالب بنجاح'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _previewTemplate(_MessageTemplate template) async {
    final text = _preview(
      _texts[template.id] ?? template.defaultText,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(template.icon),
              const SizedBox(width: 10),
              Expanded(child: Text('معاينة: ${template.title}')),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                child: SelectableText(
                  text,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                  ),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetTemplate(_MessageTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إعادة القالب الأصلي'),
          content: Text(
            'هل تريد إعادة رسالة «${template.title}» إلى الصيغة الأصلية؟',
            textDirection: TextDirection.rtl,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('إعادة'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _texts[template.id] = template.defaultText;
      });
    }
  }

  Widget _templateCard(_MessageTemplate template) {
    final text = _texts[template.id] ?? template.defaultText;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(template.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(template.description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
              child: Text(
                text,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
                style: const TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => _editTemplate(template),
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل وإعادة صياغة'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _previewTemplate(template),
                  icon: const Icon(Icons.visibility),
                  label: const Text('معاينة'),
                ),
                IconButton(
                  tooltip: 'إعادة الصيغة الأصلية',
                  onPressed: () => _resetTemplate(template),
                  icon: const Icon(Icons.restore),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مركز الرسائل والإشعارات'),
        actions: [
          IconButton(
            tooltip: 'معلومات المتغيرات',
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text('المتغيرات'),
                    content: const Text(
                      'يمكن استخدام المتغيرات داخل أي قالب، وسيتم استبدالها '
                      'بالبيانات المناسبة عند ربط الرسالة بملف المريض أو العملية.',
                      textDirection: TextDirection.rtl,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('حسنًا'),
                      ),
                    ],
                  );
                },
              );
            },
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.mark_unread_chat_alt,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مركز الرسائل والإشعارات',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'إدارة قوالب الرسائل ومعاينتها وإعادة صياغتها قبل إرسالها.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          for (final template in _templates) _templateCard(template),
        ],
      ),
    );
  }
}
