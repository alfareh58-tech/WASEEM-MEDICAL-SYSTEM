import 'package:flutter/material.dart';

import '../services/database_service.dart';
import 'add_patient_screen.dart';
import 'patient_details_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, Object?>> patients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadPatients() async {
    if (mounted) {
      setState(() => loading = true);
    }

    try {
      final result = await DatabaseService.instance.patients(
        search: searchController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        patients = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر تحميل بيانات المرضى: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> openAddPatient() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPatientScreen(),
      ),
    );

    if (!mounted) return;

    await loadPatients();
  }

  Future<void> openPatient(int patientId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailsScreen(
          patientId: patientId,
        ),
      ),
    );

    if (!mounted) return;

    await loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إدارة المرضى',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: loading ? null : loadPatients,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddPatient,
        icon: const Icon(Icons.person_add),
        label: const Text('مريض جديد'),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: searchController,
              textDirection: TextDirection.rtl,
              textInputAction: TextInputAction.search,
              onChanged: (_) => loadPatients(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'ابحث بالاسم أو الهاتف أو رقم الملف',
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح البحث',
                        onPressed: () {
                          searchController.clear();
                          loadPatients();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : patients.isEmpty
                    ? _emptyState()
                    : RefreshIndicator(
                        onRefresh: loadPatients,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            4,
                            12,
                            100,
                          ),
                          itemCount: patients.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, index) {
                            return _patientCard(
                              patients[index],
                              index,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _patientCard(
    Map<String, Object?> patient,
    int index,
  ) {
    final id = patient['id'];

    final patientId = id is int
        ? id
        : int.tryParse(id?.toString() ?? '');

    final name = _text(patient['full_name']);
    final fileNo = _text(patient['file_no']);
    final phone = _text(patient['phone']);
    final department = _text(patient['department']);

    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),

        leading: CircleAvatar(
          radius: 25,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            [
              if (fileNo.isNotEmpty) 'رقم الملف: $fileNo',
              if (phone.isNotEmpty) 'الهاتف: $phone',
              if (department.isNotEmpty) department,
            ].join(' • '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        trailing: PopupMenuButton<String>(
          tooltip: 'خيارات المريض',
          onSelected: (value) {
            if (value == 'open' && patientId != null) {
              openPatient(patientId);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem<String>(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.folder_open),
                  SizedBox(width: 10),
                  Text('فتح الملف'),
                ],
              ),
            ),
          ],
        ),

        onTap: patientId == null
            ? null
            : () => openPatient(patientId),
      ),
    );
  }

  Widget _emptyState() {
    final hasSearch = searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch
                  ? Icons.search_off
                  : Icons.people_outline,
              size: 70,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.55),
            ),

            const SizedBox(height: 16),

            Text(
              hasSearch
                  ? 'لا توجد نتائج مطابقة للبحث'
                  : 'لا توجد بيانات مرضى',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              hasSearch
                  ? 'جرّب البحث باسم مختلف أو برقم الهاتف أو رقم الملف.'
                  : 'يمكنك البدء بتسجيل أول مريض في النظام.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            if (!hasSearch)
              FilledButton.icon(
                onPressed: openAddPatient,
                icon: const Icon(Icons.person_add),
                label: const Text('تسجيل مريض جديد'),
              ),
          ],
        ),
      ),
    );
  }

  String _text(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text;
  }
}
