import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService settings = SettingsService.instance;

  final centerNameController = TextEditingController();
  final commercialNameController = TextEditingController();
  final descriptionController = TextEditingController();

  final addressController = TextEditingController();
  final cityController = TextEditingController();

  final phoneController = TextEditingController();
  final whatsappController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();

  final taxController = TextEditingController();

  final invoiceNameController = TextEditingController();
  final invoiceAddressController = TextEditingController();
  final invoicePhoneController = TextEditingController();
  final invoiceFooterController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  Uint8List? logoBytes;

  bool showLogoOnInvoice = true;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // ============================================================
  // تحميل البيانات
  // ============================================================

  Future<void> _loadSettings() async {
    centerNameController.text = await settings.centerName();
    commercialNameController.text = await settings.commercialName();
    descriptionController.text = await settings.centerDescription();

    addressController.text = await settings.address();
    cityController.text = await settings.city();

    phoneController.text = await settings.supportPhone();
    whatsappController.text = await settings.whatsappPhone();
    emailController.text = await settings.email();
    websiteController.text = await settings.website();

    taxController.text = await settings.taxNumber();

    invoiceNameController.text = await settings.invoiceName();
    invoiceAddressController.text = await settings.invoiceAddress();
    invoicePhoneController.text = await settings.invoicePhone();
    invoiceFooterController.text = await settings.invoiceFooter();

    showLogoOnInvoice = await settings.showLogoOnInvoice();

    final savedLogo = await settings.logoBase64();

    if (savedLogo.isNotEmpty) {
      try {
        logoBytes = base64Decode(savedLogo);
      } catch (_) {
        logoBytes = null;
      }
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  // ============================================================
  // اختيار الشعار
  // ============================================================

  Future<void> _pickLogo() async {
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        logoBytes = bytes;
      });

      await settings.setLogoBase64(
        base64Encode(bytes),
      );

      if (!mounted) return;

      _showMessage('تم حفظ شعار المركز');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'تعذر اختيار الشعار',
        error: true,
      );
    }
  }

  // ============================================================
  // حذف الشعار
  // ============================================================

  Future<void> _removeLogo() async {
    await settings.removeLogo();

    if (!mounted) return;

    setState(() {
      logoBytes = null;
    });

    _showMessage('تم حذف الشعار');
  }

  // ============================================================
  // حفظ جميع البيانات
  // ============================================================

  Future<void> _save() async {
    if (centerNameController.text.trim().isEmpty) {
      _showMessage(
        'يرجى إدخال اسم المركز أو العيادة',
        error: true,
      );
      return;
    }

    setState(() {
      saving = true;
    });

    await settings.setCenterName(
      centerNameController.text.trim(),
    );

    await settings.setCommercialName(
      commercialNameController.text.trim(),
    );

    await settings.setCenterDescription(
      descriptionController.text.trim(),
    );

    await settings.setAddress(
      addressController.text.trim(),
    );

    await settings.setCity(
      cityController.text.trim(),
    );

    await settings.setSupportPhone(
      phoneController.text.trim(),
    );

    await settings.setWhatsappPhone(
      whatsappController.text.trim(),
    );

    await settings.setEmail(
      emailController.text.trim(),
    );

    await settings.setWebsite(
      websiteController.text.trim(),
    );

    await settings.setTaxNumber(
      taxController.text.trim(),
    );

    await settings.setInvoiceName(
      invoiceNameController.text.trim(),
    );

    await settings.setInvoiceAddress(
      invoiceAddressController.text.trim(),
    );

    await settings.setInvoicePhone(
      invoicePhoneController.text.trim(),
    );

    await settings.setInvoiceFooter(
      invoiceFooterController.text.trim(),
    );

    await settings.setShowLogoOnInvoice(
      showLogoOnInvoice,
    );

    if (!mounted) return;

    setState(() {
      saving = false;
    });

    _showMessage('تم حفظ بيانات المركز بنجاح');
  }

  // ============================================================
  // رسالة
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // حقل إدخال
  // ============================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          prefixIcon: icon == null ? null : Icon(icon),
        ),
      ),
    );
  }

  // ============================================================
  // عنوان القسم
  // ============================================================

  Widget _sectionTitle(
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // بطاقة
  // ============================================================

  Widget _card({
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  // ============================================================
  // واجهة الشعار
  // ============================================================

  Widget _logoSection() {
    return _card(
      child: Column(
        children: [
          _sectionTitle(
            'شعار المركز',
            Icons.image_rounded,
          ),
          const SizedBox(height: 4),
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant,
              ),
            ),
            child: logoBytes == null
                ? const Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_hospital_rounded,
                        size: 55,
                      ),
                      SizedBox(height: 8),
                      Text('لا يوجد شعار'),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      logoBytes!,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(Icons.upload_rounded),
                label: Text(
                  logoBytes == null
                      ? 'اختيار الشعار'
                      : 'تغيير الشعار',
                ),
              ),
              if (logoBytes != null)
                TextButton.icon(
                  onPressed: _removeLogo,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                  ),
                  label: const Text('حذف'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'يفضل استخدام شعار واضح بجودة جيدة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // بناء الشاشة
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المركز'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            14,
            14,
            14,
            100,
          ),
          children: [
            // ----------------------------------------------------
            // تعريف المركز
            // ----------------------------------------------------

            _card(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(
                    'بيانات المركز والعيادة',
                    Icons.local_hospital_rounded,
                  ),

                  _field(
                    controller: centerNameController,
                    label: 'اسم المركز / العيادة',
                    hint: 'مثال: المركز الأول للعلاج الطبيعي والتأهيل',
                    icon: Icons.business_rounded,
                    required: true,
                  ),

                  _field(
                    controller: commercialNameController,
                    label: 'الاسم التجاري',
                    hint: 'الاسم التجاري إن وجد',
                    icon: Icons.storefront_rounded,
                  ),

                  _field(
                    controller: descriptionController,
                    label: 'وصف المركز',
                    hint: 'نبذة مختصرة عن المركز والخدمات',
                    icon: Icons.description_rounded,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // الشعار
            // ----------------------------------------------------

            _logoSection(),

            // ----------------------------------------------------
            // العنوان
            // ----------------------------------------------------

            _card(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(
                    'العنوان',
                    Icons.location_on_rounded,
                  ),

                  _field(
                    controller: addressController,
                    label: 'العنوان بالتفصيل',
                    hint: 'الشارع، الحي، بجوار...',
                    icon: Icons.place_rounded,
                    maxLines: 2,
                  ),

                  _field(
                    controller: cityController,
                    label: 'المدينة / المحافظة',
                    hint: 'مثال: دمت - الضالع',
                    icon: Icons.location_city_rounded,
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // التواصل
            // ----------------------------------------------------

            _card(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(
                    'بيانات التواصل',
                    Icons.contact_phone_rounded,
                  ),

                  _field(
                    controller: phoneController,
                    label: 'رقم الهاتف',
                    hint: 'رقم المركز',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),

                  _field(
                    controller: whatsappController,
                    label: 'رقم واتساب',
                    hint: 'رقم واتساب المركز',
                    icon: Icons.chat_rounded,
                    keyboardType: TextInputType.phone,
                  ),

                  _field(
                    controller: emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'example@email.com',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  _field(
                    controller: websiteController,
                    label: 'الموقع الإلكتروني',
                    hint: 'اختياري',
                    icon: Icons.language_rounded,
                    keyboardType: TextInputType.url,
                  ),

                  _field(
                    controller: taxController,
                    label: 'الرقم الضريبي',
                    hint: 'اختياري',
                    icon: Icons.receipt_long_rounded,
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // بيانات الفاتورة
            // ----------------------------------------------------

            _card(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle(
                    'بيانات الفواتير والطباعة',
                    Icons.receipt_long_rounded,
                  ),

                  _field(
                    controller: invoiceNameController,
                    label: 'اسم المركز في الفاتورة',
                    hint: 'يُترك فارغًا لاستخدام اسم المركز الأساسي',
                    icon: Icons.title_rounded,
                  ),

                  _field(
                    controller: invoiceAddressController,
                    label: 'العنوان في الفاتورة',
                    hint: 'العنوان الذي يظهر في الفاتورة',
                    icon: Icons.location_on_rounded,
                    maxLines: 2,
                  ),

                  _field(
                    controller: invoicePhoneController,
                    label: 'رقم الهاتف في الفاتورة',
                    hint: 'رقم الهاتف الذي يظهر في الفاتورة',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),

                  _field(
                    controller: invoiceFooterController,
                    label: 'العبارة أسفل الفاتورة',
                    hint: 'مثال: شكرًا لثقتكم بنا',
                    icon: Icons.notes_rounded,
                    maxLines: 2,
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'إظهار الشعار في الفواتير',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'سيظهر شعار المركز في رأس الفاتورة عند الطباعة أو إنشاء PDF.',
                    ),
                    value: showLogoOnInvoice,
                    onChanged: (value) {
                      setState(() {
                        showLogoOnInvoice = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // ----------------------------------------------------
            // الحفظ
            // ----------------------------------------------------

            const SizedBox(height: 4),

            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: saving ? null : _save,
                icon: saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.save_rounded,
                      ),
                label: Text(
                  saving
                      ? 'جارٍ الحفظ...'
                      : 'حفظ بيانات المركز',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            // معلومات النظام
            // ----------------------------------------------------

            _card(
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(
                      Icons.support_agent_rounded,
                    ),
                    title: Text('الدعم الفني'),
                    subtitle: Text('774486588'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.medical_services_rounded,
                    ),
                    title: Text('اسم النظام'),
                    subtitle: Text(
                      'وسيم ميديكال — WASEEM MEDICAL PRO',
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

  @override
  void dispose() {
    centerNameController.dispose();
    commercialNameController.dispose();
    descriptionController.dispose();

    addressController.dispose();
    cityController.dispose();

    phoneController.dispose();
    whatsappController.dispose();
    emailController.dispose();
    websiteController.dispose();

    taxController.dispose();

    invoiceNameController.dispose();
    invoiceAddressController.dispose();
    invoicePhoneController.dispose();
    invoiceFooterController.dispose();

    super.dispose();
  }
}
