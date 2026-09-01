import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Kontak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5FB),
      ),
      home: const HomePage(),
    );
  }
}

// =====================================================
// HALAMAN UTAMA
// =====================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> contacts = [];

  // DATA FAVORIT UNTUK TUGAS 3
  final List<Map<String, String>> favoriteContacts = [
    {
      'name': 'Venska Fellicia Pertiwi',
      'email': 'venskafalensia@gmail.com',
      'phone': '08122557794',
    },
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _bukaTambahKontak() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (context) => const TambahKontakPage(),
      ),
    );

    if (result != null) {
      setState(() {
        contacts.add(result);
      });

      _tabController.animateTo(0);
    }
  }

  void _bukaTentang() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TentangPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= APPBAR =================
      appBar: AppBar(
        automaticallyImplyLeading: true,

        title: const Text(
          'BUKU KONTAK',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4568DC),
                Color(0xFF7048E8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,

          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.person),
              text: 'Kontak',
            ),
            Tab(
              icon: Icon(Icons.star),
              text: 'Favorit',
            ),
          ],
        ),
      ),

      // ================= MENU GARIS TIGA =================
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                padding: const EdgeInsets.all(24),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4568DC),
                      Color(0xFF7048E8),
                    ],
                  ),
                ),

                child: const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'BUKU KONTAK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(
                  Icons.person,
                  color: Color(0xFF6547DD),
                ),
                title: const Text('Kontak'),
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(0);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.add,
                  color: Color(0xFF6547DD),
                ),
                title: const Text('Tambah Kontak'),
                onTap: () {
                  Navigator.pop(context);
                  _bukaTambahKontak();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.star,
                  color: Color(0xFF6547DD),
                ),
                title: const Text('Favorit'),
                onTap: () {
                  Navigator.pop(context);
                  _tabController.animateTo(1);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.info,
                  color: Color(0xFF6547DD),
                ),
                title: const Text('Tentang'),
                onTap: () {
                  Navigator.pop(context);
                  _bukaTentang();
                },
              ),
            ],
          ),
        ),
      ),

      // ================= ISI TAB =================
      body: TabBarView(
        controller: _tabController,
        children: [
          KontakListView(
            contacts: contacts,
          ),
          FavoritListView(
            favorites: favoriteContacts,
          ),
        ],
      ),

      // ================= TOMBOL TAMBAH =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6547DD),
        onPressed: _bukaTambahKontak,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

// =====================================================
// HALAMAN KONTAK
// =====================================================

class KontakListView extends StatelessWidget {
  final List<Map<String, String>> contacts;

  const KontakListView({
    super.key,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),

            leading: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4568DC),
                    Color(0xFF7048E8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),

            title: Text(
              contact['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Text(
              'Email: ${contact['email'] ?? ''}\n'
              'HP: ${contact['phone'] ?? ''}',
            ),
          ),
        );
      },
    );
  }
}

// =====================================================
// HALAMAN FAVORIT - TUGAS 3
// =====================================================

class FavoritListView extends StatelessWidget {
  final List<Map<String, String>> favorites;

  const FavoritListView({
    super.key,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada kontak favorit.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final contact = favorites[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),

          child: ListTile(
            contentPadding: const EdgeInsets.all(12),

            leading: Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4568DC),
                    Color(0xFF7048E8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.star,
                color: Colors.white,
              ),
            ),

            title: Text(
              contact['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Text(
              'Email: ${contact['email'] ?? ''}\n'
              'HP: ${contact['phone'] ?? ''}',
            ),
          ),
        );
      },
    );
  }
}

// =====================================================
// HALAMAN TAMBAH KONTAK
// =====================================================

class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() =>
      _TambahKontakPageState();
}

class _TambahKontakPageState
    extends State<TambahKontakPage> {
  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _simpanKontak() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama lengkap wajib diisi'),
        ),
      );
      return;
    }

    final Map<String, String> newContact = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
    };

    Navigator.pop(context, newContact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Kontak',
          style: TextStyle(color: Colors.white),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4568DC),
                Color(0xFF7048E8),
              ],
            ),
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),

            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  keyboardType:
                      TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Handphone',
                    prefixIcon: Icon(
                      Icons.phone_outlined,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton.icon(
                    onPressed: _simpanKontak,

                    icon: const Icon(Icons.save),

                    label: const Text(
                      'Simpan Kontak',
                    ),

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF6547DD),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// HALAMAN TENTANG
// =====================================================

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang',
          style: TextStyle(color: Colors.white),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4568DC),
                Color(0xFF7048E8),
              ],
            ),
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundImage:
                    AssetImage('assets/images/foto_pribadi.jpeg'),
              ),

              const SizedBox(height: 16),

              const Text(
                'Venska Fellicia Pertiwi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text('XII RPL B'),

              const SizedBox(height: 3),

              const Text('SMKN 5 Surakarta'),
            ],
          ),
        ),
      ),
    );
  }
}