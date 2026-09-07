import 'dart:async';

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

// =====================================================
// MODEL DATA KONTAK (TUGAS 4 - NULL SAFETY)
// =====================================================

class Kontak {
  final String name;
  final String email;
  final String phone;

  // Tidak semua kontak wajib punya kategori, jadi nullable (String?)
  final String? kategori;

  Kontak({
    required this.name,
    required this.email,
    required this.phone,
    this.kategori, // opsional, boleh tidak diisi
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

  final List<Kontak> contacts = [];

  // DATA FAVORIT UNTUK TUGAS 3
  final List<Kontak> favoriteContacts = [
    Kontak(
      name: 'Venska Fellicia Pertiwi',
      email: 'venskafalensia@gmail.com',
      phone: '08122557794',
      kategori: 'Keluarga',
    ),
  ];

  // =====================================================
  // PENCARIAN REAL-TIME DENGAN STREAM (TUGAS 6)
  // =====================================================

  // Stream broadcast supaya bisa didengarkan berkali-kali (StreamBuilder
  // akan rebuild setiap kali build dipanggil ulang oleh Flutter).
  final StreamController<String> _searchController =
      StreamController<String>.broadcast();

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
    _searchController.close(); // supaya tidak terjadi memory leak
    super.dispose();
  }

  Future<void> _bukaTambahKontak() async {
    final result = await Navigator.push<Kontak>(
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

  // Filter kontak berdasarkan nama ATAU kategori yang mengandung keyword
  List<Kontak> _filterContacts(String keyword) {
    final String lowerKeyword = keyword.toLowerCase();

    if (lowerKeyword.isEmpty) {
      return contacts;
    }

    return contacts.where((kontak) {
      final bool cocokNama =
          kontak.name.toLowerCase().contains(lowerKeyword);
      final bool cocokKategori =
          (kontak.kategori ?? '').toLowerCase().contains(lowerKeyword);
      return cocokNama || cocokKategori;
    }).toList();
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
          // Tab Kontak: kotak pencarian di atas + daftar kontak
          // yang difilter secara real-time lewat StreamBuilder
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau kategori...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (teks) {
                    _searchController.add(teks);
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<String>(
                  stream: _searchController.stream,
                  initialData: '',
                  builder: (context, snapshot) {
                    final String keyword = snapshot.data ?? '';
                    final List<Kontak> hasilFilter =
                        _filterContacts(keyword);

                    return KontakListView(
                      contacts: hasilFilter,
                    );
                  },
                ),
              ),
            ],
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
  final List<Kontak> contacts;

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

        final String initial =
            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),

            leading: Container(
              width: 55,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4568DC),
                    Color(0xFF7048E8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            title: Text(
              contact.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            // Null-aware operator (??): tampilkan 'Tanpa kategori'
            // kalau contact.kategori bernilai null
            subtitle: Text(
              'Email: ${contact.email}\n'
              'HP: ${contact.phone}\n'
              'Kategori: ${contact.kategori ?? 'Tanpa kategori'}',
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
  final List<Kontak> favorites;

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
              contact.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            subtitle: Text(
              'Email: ${contact.email}\n'
              'HP: ${contact.phone}\n'
              'Kategori: ${contact.kategori ?? 'Tanpa kategori'}',
            ),
          ),
        );
      },
    );
  }
}

// =====================================================
// HALAMAN TAMBAH KONTAK (TUGAS 5 - FORM & VALIDASI)
// =====================================================

class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() =>
      _TambahKontakPageState();
}

class _TambahKontakPageState
    extends State<TambahKontakPage> {
  // Key untuk mengakses dan memvalidasi Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  final TextEditingController kategoriController =
      TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    kategoriController.dispose();
    super.dispose();
  }

  void _simpanKontak() {
    // Validasi seluruh field di dalam Form terlebih dahulu.
    // Kontak hanya disimpan kalau semua validator lolos (true).
    final bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    final String kategoriInput = kategoriController.text.trim();
    final String? kategoriValue =
        kategoriInput.isEmpty ? null : kategoriInput;

    final Kontak newContact = Kontak(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      kategori: kategoriValue,
    );

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

            // Seluruh isi form dibungkus widget Form
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Nama wajib diisi
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama lengkap wajib diisi';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Email wajib diisi dan harus mengandung '@'
                  TextFormField(
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
                    validator: (value) {
                      final String input = value?.trim() ?? '';
                      if (input.isEmpty) {
                        return 'Email wajib diisi';
                      }
                      if (!input.contains('@')) {
                        return 'Email harus mengandung karakter @';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // No Handphone: hanya angka, minimal 10 digit
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Handphone',
                      prefixIcon: Icon(
                        Icons.phone_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final String input = value?.trim() ?? '';
                      if (input.isEmpty) {
                        return 'Nomor handphone wajib diisi';
                      }
                      final bool hanyaAngka =
                          RegExp(r'^[0-9]+$').hasMatch(input);
                      if (!hanyaAngka) {
                        return 'Nomor handphone hanya boleh angka';
                      }
                      if (input.length < 10) {
                        return 'Nomor handphone minimal 10 digit';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Kategori tetap opsional, tanpa validator (Tugas 4)
                  TextFormField(
                    controller: kategoriController,
                    decoration: const InputDecoration(
                      labelText: 'Kategori (opsional)',
                      hintText: 'Keluarga / Teman / Kerja',
                      prefixIcon: Icon(
                        Icons.label_outline,
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