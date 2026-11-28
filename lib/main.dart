
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/pdf_text_service.dart';
import 'services/notice_parser_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ykphsrcysjwffngrdcbq.supabase.co',
    publishableKey: 'sb_publishable_P8w4nS-twsIt4FdNtr5_Cg_J5Urzdli',
  );

  runApp(const SmartNoticeApp());
}

// MAIN APP

class SmartNoticeApp extends StatelessWidget {
  const SmartNoticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Notice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2457C5),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// LOGIN SCREEN

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscurePassword = true;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().loginStudent(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('User login failed.');
      }

      final profile = await Supabase.instance.client
          .from('students')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = profile['role'].toString();
      debugPrint('Logged in user role: $role');

      if (role != 'admin' && role != 'student') {
        throw Exception('Invalid user role.');
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            if (role == 'admin') {
              return const AdminDashboardScreen();
            } else {
              return const StudentDashboardScreen();
            }
          },
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 25),
                const Icon(
                  Icons.notifications_active_rounded,
                  size: 75,
                  color: Color(0xFF2457C5),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Smart Notice',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF18366F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Stay updated. Never miss an important notice.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Login to access your student dashboard.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Email Address',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2457C5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// REGISTRATION SCREEN

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  String? selectedDepartment;
  String? selectedYear;

  final List<String> departments = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
  ];

  final List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registerStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await AuthService().registerStudent(
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        department: selectedDepartment!,
        academicYear: selectedYear!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created! Please check your email if confirmation is required.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFFF5F7FC),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 65,
                  color: Color(0xFF2457C5),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Join Smart Notice!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF18366F),
                  ),
                ),
                const SizedBox(height: 25),
                const Text('Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: _inputDecoration(
                    'Enter your full name',
                    Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Email Address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    'Enter your email',
                    Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                    if (!pattern.hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Department'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  decoration: _inputDecoration(null, Icons.school_outlined),
                  hint: const Text('Select your department'),
                  items: departments.map((department) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(department),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedDepartment = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your department';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Academic Year'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedYear,
                  decoration: _inputDecoration(null, null),
                  hint: const Text('Select your year'),
                  items: years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedYear = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your academic year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : registerStudent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2457C5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// REUSABLE INPUT DECORATION

InputDecoration _inputDecoration(String? hint, IconData? icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

// ADMIN DASHBOARD

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, String>> notices = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'All';
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Examination',
    'Placement',
    'Events',
    'Academics',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    fetchNotices();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchNotices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await Supabase.instance.client
          .from('notices')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        notices = data.map<Map<String, String>>((notice) {
          return {
            'id': (notice['id'] ?? '').toString(),
            'title': (notice['title'] ?? '').toString(),
            'category': (notice['category'] ?? 'General').toString(),
            'date': (notice['notice_date'] ?? '').toString(),
            'description': (notice['description'] ?? '').toString(),
            'pdf_url': (notice['pdf_url'] ?? '').toString(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    try {
      await AuthService().logoutStudent();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $error')),
      );
    }
  }

  Future<void> openAddNotice() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNoticeScreen()),
    );

    if (result == true && mounted) {
      fetchNotices();
    }
  }

  Future<void> openEditNotice(Map<String, String> notice) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoticeScreen(notice: notice),
      ),
    );

    if (result == true && mounted) {
      fetchNotices();
    }
  }

  Future<void> confirmDeleteNotice(Map<String, String> notice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Notice'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${notice['title']}"?\n\nThis will permanently remove the notice for all students.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await Supabase.instance.client
            .from('notices')
            .delete()
            .eq('id', notice['id']!);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notice deleted successfully!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        fetchNotices();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete notice: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotices = notices.where((notice) {
      final matchesCategory = selectedCategory == 'All' ||
          notice['category'] == selectedCategory;
      final searchText = searchController.text.toLowerCase();
      final matchesSearch = notice['title']!.toLowerCase().contains(searchText) ||
          notice['description']!.toLowerCase().contains(searchText);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: fetchNotices,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openAddNotice,
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Notice'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchNotices,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2457C5), Color(0xFF18366F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Portal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Publish, edit and manage college notices.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: openAddNotice,
                        icon: const Icon(Icons.add_circle, color: Colors.white, size: 32),
                        tooltip: 'Add Notice',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Notices',
                        notices.length.toString(),
                        Icons.campaign,
                        const Color(0xFF2457C5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Exams',
                        notices.where((n) => n['category'] == 'Examination').length.toString(),
                        Icons.school,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Placements',
                        notices.where((n) => n['category'] == 'Placement').length.toString(),
                        Icons.work,
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Search Bar
                TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search notices by keyword...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Chips Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => selectedCategory = cat);
                          },
                          selectedColor: const Color(0xFF2457C5),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          backgroundColor: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Notices Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Notices (${filteredNotices.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF18366F),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: openAddNotice,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Notice'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Notices List
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF2457C5)),
                    ),
                  )
                else if (errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 40),
                          const SizedBox(height: 8),
                          Text('Error: $errorMessage'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: fetchNotices,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filteredNotices.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.note_alt_outlined, size: 55, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text(
                          'No notices found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap the button below to add your first notice.',
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: openAddNotice,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Notice Now'),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredNotices.length,
                    itemBuilder: (context, index) {
                      final notice = filteredNotices[index];
                      final hasPdf = notice['pdf_url'] != null &&
                          notice['pdf_url']!.isNotEmpty;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        color: Colors.white,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NoticeDetailsScreen(notice: notice),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD8E4FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        notice['category'] ?? 'General',
                                        style: const TextStyle(
                                          color: Color(0xFF2457C5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (hasPdf)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    Text(
                                      notice['date'] ?? '',
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  notice['title'] ?? 'Untitled Notice',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF18366F),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notice['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => openEditNotice(notice),
                                      icon: const Icon(Icons.edit, size: 16, color: Color(0xFF2457C5)),
                                      label: const Text(
                                        'Edit',
                                        style: TextStyle(color: Color(0xFF2457C5), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => confirmDeleteNotice(notice),
                                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                      label: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ADD NOTICE SCREEN

class AddNoticeScreen extends StatefulWidget {
  const AddNoticeScreen({super.key});

  @override
  State<AddNoticeScreen> createState() => _AddNoticeScreenState();
}

class _AddNoticeScreenState extends State<AddNoticeScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String selectedCategory = 'General';
  String selectedDepartment = 'All Departments';
  String selectedYear = 'All Years';
  DateTime? selectedDate;
  DateTime? selectedDeadline;

  PlatformFile? selectedPdf;
  String extractedPdfText = '';
  bool isLoading = false;

  final List<String> categories = NoticeParserService.categories;
  final List<String> departments = NoticeParserService.departments;
  final List<String> academicYears = NoticeParserService.academicYears;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void autoDetectAll([String? customText]) {
    final text = customText ?? '${titleController.text} ${descriptionController.text}';
    if (text.trim().isEmpty) return;

    final cat = NoticeParserService.detectCategory(text);
    final dept = NoticeParserService.detectDepartment(text);
    final yr = NoticeParserService.detectAcademicYear(text);
    final deadline = NoticeParserService.detectDeadline(text);

    setState(() {
      selectedCategory = cat;
      selectedDepartment = dept;
      selectedYear = yr;
      if (deadline != null) {
        selectedDeadline = deadline;
        selectedDate ??= deadline;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Auto-detected: $cat • $dept • $yr'
          '${deadline != null ? ' • Deadline: ${deadline.day}/${deadline.month}/${deadline.year}' : ''}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // SELECT PDF FROM DEVICE
  Future<void> choosePdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final pdfBytes = file.bytes;

      if (pdfBytes == null) {
        throw Exception('Could not read PDF data.');
      }

      final extractedText = PdfTextService.extractText(pdfBytes);

      if (!mounted) return;

      setState(() {
        selectedPdf = file;
        extractedPdfText = extractedText;

        if (descriptionController.text.trim().isEmpty &&
            extractedText.trim().isNotEmpty) {
          descriptionController.text = extractedText;
        }
      });

      // Automatically detect all metadata from title + extracted PDF text
      final fullText = '${titleController.text} $extractedText';
      autoDetectAll(fullText);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            extractedText.trim().isEmpty
                ? 'PDF selected, but no readable text was found.'
                : 'PDF text extracted and auto-categorized successfully!',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not process PDF: $error')),
      );
    }
  }

  // SELECT NOTICE DATE / DEADLINE
  Future<void> chooseDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // UPLOAD PDF AND PUBLISH NOTICE + SEND NOTIFICATIONS
  Future<void> saveNotice() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a notice date.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? pdfUrl;

      // 1. Upload selected PDF to Supabase Storage
      if (selectedPdf != null && selectedPdf!.bytes != null) {
        final pdfPath = '${DateTime.now().millisecondsSinceEpoch}.pdf';

        await Supabase.instance.client.storage
            .from('notice-pdfs')
            .uploadBinary(
              pdfPath,
              selectedPdf!.bytes!,
              fileOptions: const FileOptions(
                contentType: 'application/pdf',
                upsert: false,
              ),
            );

        pdfUrl = Supabase.instance.client.storage
            .from('notice-pdfs')
            .getPublicUrl(pdfPath);
      }

      // Format notice date
      final dateFormatted =
          '${selectedDate!.year.toString().padLeft(4, '0')}-'
          '${selectedDate!.month.toString().padLeft(2, '0')}-'
          '${selectedDate!.day.toString().padLeft(2, '0')}';

      // 2. Save notice in database
      await Supabase.instance.client.from('notices').insert({
        'title': titleController.text.trim(),
        'category': selectedCategory,
        'description': descriptionController.text.trim(),
        'notice_date': dateFormatted,
        'pdf_url': pdfUrl,
      });

      // 3. Dispatch Notifications to relevant students
      try {
        final students = await Supabase.instance.client
            .from('students')
            .select('id, department, academic_year');

        final notificationsToInsert = <Map<String, dynamic>>[];
        for (final s in students) {
          final sDept = s['department']?.toString();
          final sYear = s['academic_year']?.toString();

          final deptMatch = selectedDepartment == 'All Departments' ||
              sDept == null ||
              sDept.toLowerCase().contains(selectedDepartment.toLowerCase()) ||
              selectedDepartment.toLowerCase().contains(sDept.toLowerCase());

          final yearMatch = selectedYear == 'All Years' ||
              sYear == null ||
              sYear == selectedYear;

          if (deptMatch && yearMatch) {
            notificationsToInsert.add({
              'student_id': s['id'],
              'title': 'New Notice: ${titleController.text.trim()}',
              'message': descriptionController.text.trim().length > 100
                  ? '${descriptionController.text.trim().substring(0, 100)}...'
                  : descriptionController.text.trim(),
              'category': selectedCategory,
              'is_read': false,
            });
          }
        }

        if (notificationsToInsert.isNotEmpty) {
          await Supabase.instance.client
              .from('notifications')
              .insert(notificationsToInsert);
          debugPrint('Created ${notificationsToInsert.length} notifications.');
        }
      } catch (notifErr) {
        debugPrint('Could not create notification records: $notifErr');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice and PDF published successfully!')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not publish notice: $error')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Add New Notice'),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Auto-Detect All Fields',
            onPressed: () => autoDetectAll(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Notice Title
              const Text(
                'Notice Title',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter notice title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category with Auto-Detect badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => autoDetectAll(),
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('Auto-Detect All', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
              const SizedBox(height: 20),

              // Department & Academic Year row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target Dept',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedDepartment,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          items: departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept,
                              child: Text(dept, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedDepartment = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Target Year',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedYear,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          items: academicYears.map((yr) {
                            return DropdownMenuItem(
                              value: yr,
                              child: Text(yr, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedYear = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Notice Description
              const Text(
                'Notice Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter complete notice details',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Notice Date / Deadline
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Notice Date / Deadline',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (selectedDeadline != null)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Text(
                                  '(Detected)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : chooseDate,
                          icon: const Icon(Icons.calendar_month),
                          label: Text(
                            selectedDate == null
                                ? 'Select Date'
                                : '${selectedDate!.day}/'
                                    '${selectedDate!.month}/'
                                    '${selectedDate!.year}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Attach PDF
              const Text(
                'Attach Notice PDF',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isLoading ? null : choosePdf,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                label: Text(
                  selectedPdf == null
                      ? 'Choose PDF File'
                      : selectedPdf!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selectedPdf != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'PDF selected & text extracted',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() => selectedPdf = null);
                            },
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 30),

              // Publish Button
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : saveNotice,
                  icon: const Icon(Icons.publish),
                  label: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'PUBLISH NOTICE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2457C5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// EDIT NOTICE SCREEN

class EditNoticeScreen extends StatefulWidget {
  final Map<String, String> notice;

  const EditNoticeScreen({super.key, required this.notice});

  @override
  State<EditNoticeScreen> createState() => _EditNoticeScreenState();
}

class _EditNoticeScreenState extends State<EditNoticeScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController descriptionController;

  late String selectedCategory;
  late String selectedDepartment;
  late String selectedYear;
  DateTime? selectedDate;
  DateTime? selectedDeadline;

  PlatformFile? selectedPdf;
  bool isLoading = false;

  final List<String> categories = NoticeParserService.categories;
  final List<String> departments = NoticeParserService.departments;
  final List<String> academicYears = NoticeParserService.academicYears;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.notice['title'] ?? '');
    descriptionController = TextEditingController(text: widget.notice['description'] ?? '');

    selectedCategory = categories.contains(widget.notice['category'])
        ? widget.notice['category']!
        : 'General';

    try {
      final dateStr = widget.notice['date'];
      if (dateStr != null && dateStr.isNotEmpty) {
        selectedDate = DateTime.tryParse(dateStr);
      }
    } catch (_) {}

    final fullText = '${titleController.text} ${descriptionController.text}';
    selectedDepartment = NoticeParserService.detectDepartment(fullText);
    selectedYear = NoticeParserService.detectAcademicYear(fullText);
    selectedDeadline = NoticeParserService.detectDeadline(fullText);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void autoDetectAll() {
    final text = '${titleController.text} ${descriptionController.text}';
    if (text.trim().isEmpty) return;

    final cat = NoticeParserService.detectCategory(text);
    final dept = NoticeParserService.detectDepartment(text);
    final yr = NoticeParserService.detectAcademicYear(text);
    final deadline = NoticeParserService.detectDeadline(text);

    setState(() {
      selectedCategory = cat;
      selectedDepartment = dept;
      selectedYear = yr;
      if (deadline != null) {
        selectedDeadline = deadline;
        selectedDate ??= deadline;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Auto-detected: $cat • $dept • $yr'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> choosePdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final pdfBytes = file.bytes;

      if (pdfBytes == null) {
        throw Exception('Could not read PDF bytes.');
      }

      final extractedText = PdfTextService.extractText(pdfBytes);

      if (!mounted) return;

      setState(() {
        selectedPdf = file;
        if (descriptionController.text.trim().isEmpty &&
            extractedText.trim().isNotEmpty) {
          descriptionController.text = extractedText;
        }
      });

      autoDetectAll();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New PDF selected & text parsed!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error choosing PDF: $e')),
      );
    }
  }

  Future<void> chooseDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> updateNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      String? pdfUrl = widget.notice['pdf_url'];

      if (selectedPdf != null && selectedPdf!.bytes != null) {
        final pdfPath = '${DateTime.now().millisecondsSinceEpoch}.pdf';
        await Supabase.instance.client.storage.from('notice-pdfs').uploadBinary(
          pdfPath,
          selectedPdf!.bytes!,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: false,
          ),
        );
        pdfUrl = Supabase.instance.client.storage
            .from('notice-pdfs')
            .getPublicUrl(pdfPath);
      }

      final noticeDateFormatted = selectedDate != null
          ? '${selectedDate!.year.toString().padLeft(4, '0')}-'
            '${selectedDate!.month.toString().padLeft(2, '0')}-'
            '${selectedDate!.day.toString().padLeft(2, '0')}'
          : widget.notice['date'] ?? '';

      await Supabase.instance.client.from('notices').update({
        'title': titleController.text.trim(),
        'category': selectedCategory,
        'description': descriptionController.text.trim(),
        'notice_date': noticeDateFormatted,
        if (pdfUrl != null && pdfUrl.isNotEmpty) 'pdf_url': pdfUrl,
      }).eq('id', widget.notice['id']!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notice updated successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingPdf = widget.notice['pdf_url'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Edit Notice'),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Auto-Detect',
            onPressed: autoDetectAll,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Notice Title',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter notice title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: autoDetectAll,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('Auto-Detect', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedCategory = value);
                },
              ),
              const SizedBox(height: 20),

              // Department & Academic Year
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Target Dept', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedDepartment,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          items: departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept,
                              child: Text(dept, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedDepartment = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Target Year', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedYear,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          items: academicYears.map((yr) {
                            return DropdownMenuItem(
                              value: yr,
                              child: Text(yr, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedYear = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'Notice Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Enter complete notice details',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Notice Date / Deadline',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isLoading ? null : chooseDate,
                icon: const Icon(Icons.calendar_month),
                label: Text(
                  selectedDate == null
                      ? 'Select Date'
                      : '${selectedDate!.day}/'
                          '${selectedDate!.month}/'
                          '${selectedDate!.year}',
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'PDF Document',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isLoading ? null : choosePdf,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                label: Text(
                  selectedPdf != null
                      ? 'New PDF: ${selectedPdf!.name}'
                      : (existingPdf != null && existingPdf.isNotEmpty)
                          ? 'Replace Existing PDF'
                          : 'Choose PDF File',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (selectedPdf != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text('New PDF ready to upload', style: TextStyle(color: Colors.green)),
                    ),
                    TextButton(
                      onPressed: () => setState(() => selectedPdf = null),
                      child: const Text('Cancel New PDF'),
                    ),
                  ],
                ),
              ] else if (existingPdf != null && existingPdf.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text(
                  'Notice currently has an attached PDF document.',
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
              const SizedBox(height: 30),

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : updateNotice,
                  icon: const Icon(Icons.save),
                  label: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SAVE CHANGES',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2457C5),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// STUDENT DASHBOARD

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';

  List<Map<String, String>> notices = [];

  bool isLoading = true;
  String? noticesError;

  int unreadNotificationCount = 0;

  final List<String> categories = [
    'All',
    'Examination',
    'Placement',
    'Events',
    'Academics',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    fetchNotices();
    fetchUnreadNotificationCount();
  }

  Future<void> fetchNotices() async {
    try {
      final data = await Supabase.instance.client
          .from('notices')
          .select()
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        notices = data.map<Map<String, String>>((notice) {
          return {
            'id': (notice['id'] ?? '').toString(),
            'title': (notice['title'] ?? '').toString(),
            'category': (notice['category'] ?? 'General').toString(),
            'date': (notice['notice_date'] ?? '').toString(),
            'description': (notice['description'] ?? '').toString(),
            'pdf_url': (notice['pdf_url'] ?? '').toString(),
          };
        }).toList();

        isLoading = false;
        noticesError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        noticesError = error.toString();
        isLoading = false;
      });
    }
  }

  // FETCH UNREAD NOTIFICATION COUNT

  Future<void> fetchUnreadNotificationCount() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) return;

      final data = await Supabase.instance.client
          .from('notifications')
          .select('id')
          .eq('student_id', user.id)
          .eq('is_read', false);

      if (!mounted) return;

      setState(() {
        unreadNotificationCount = data.length;
      });
    } catch (error) {
      debugPrint('Could not fetch unread count: $error');
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotices = notices.where((notice) {
      final matchesCategory = selectedCategory == 'All' ||
          notice['category'] == selectedCategory;

      final searchText = searchController.text.toLowerCase();

      final matchesSearch =
          notice['title']!.toLowerCase().contains(searchText) ||
          notice['description']!.toLowerCase().contains(searchText);

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Smart Notice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined),
                if (unreadNotificationCount > 0)
                  Positioned(
                    right: -7,
                    top: -7,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadNotificationCount > 99
                            ? '99+'
                            : unreadNotificationCount.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );

              if (!mounted) return;
              fetchUnreadNotificationCount();
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchNotices,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello, Student! 👋',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF243B70),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Stay updated with your college notices.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 22),
                TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search notices...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((category) {
                      final isSelected = selectedCategory == category;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: isSelected,
                          selectedColor: const Color(0xFF2457C5),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Latest Notices',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: CircularProgressIndicator(
                        color: Color(0xFF2457C5),
                      ),
                    ),
                  )
                else if (noticesError != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            'Could not load notices:\n$noticesError',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: fetchNotices,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filteredNotices.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Text('No notices found.'),
                    ),
                  )
                else
                  ...filteredNotices.map((notice) {
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE4ECFF),
                          child: Icon(
                            Icons.campaign,
                            color: Color(0xFF2457C5),
                          ),
                        ),
                        title: Text(
                          notice['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notice['description']!),
                              const SizedBox(height: 8),
                              Text(
                                '${notice['category']} • ${notice['date']}',
                                style: const TextStyle(
                                  color: Color(0xFF2457C5),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoticeDetailsScreen(
                                notice: notice,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// NOTICE DETAILS SCREEN

class NoticeDetailsScreen extends StatelessWidget {
  final Map<String, String> notice;

  const NoticeDetailsScreen({
    super.key,
    required this.notice,
  });

  @override
  Widget build(BuildContext context) {
    final combinedText = '${notice['title'] ?? ''} ${notice['description'] ?? ''}';
    final detectedDept = NoticeParserService.detectDepartment(combinedText);
    final detectedYear = NoticeParserService.detectAcademicYear(combinedText);
    final detectedDeadline = NoticeParserService.detectDeadline(combinedText);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Notice Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4ECFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  size: 55,
                  color: Color(0xFF2457C5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Metadata Chips: Category, Dept, Year
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  backgroundColor: const Color(0xFFD8E4FF),
                  avatar: const Icon(Icons.label, size: 16, color: Color(0xFF2457C5)),
                  label: Text(
                    notice['category'] ?? 'General',
                    style: const TextStyle(
                      color: Color(0xFF2457C5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (detectedDept != 'All Departments')
                  Chip(
                    backgroundColor: const Color(0xFFE8F5E9),
                    avatar: const Icon(Icons.domain, size: 16, color: Colors.green),
                    label: Text(
                      detectedDept,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (detectedYear != 'All Years')
                  Chip(
                    backgroundColor: const Color(0xFFFFF3E0),
                    avatar: const Icon(Icons.school, size: 16, color: Colors.deepOrange),
                    label: Text(
                      detectedYear,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            Text(
              notice['title'] ?? 'Notice',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF18366F),
              ),
            ),
            const SizedBox(height: 18),

            // Date Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Color(0xFF2457C5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notice Date / Deadline',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              (notice['date'] == null || notice['date']!.isEmpty)
                                  ? 'Not specified'
                                  : notice['date']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (detectedDeadline != null) ...[
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Text(
                                  'Deadline: ${detectedDeadline.day}/${detectedDeadline.month}/${detectedDeadline.year}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Notice Description',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                notice['description'] ?? 'No description available.',
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final pdfUrl = notice['pdf_url'];

                  if (pdfUrl == null || pdfUrl.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'No PDF is attached to this notice.',
                        ),
                      ),
                    );
                    return;
                  }

                  final uri = Uri.tryParse(pdfUrl);

                  if (uri == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid PDF link.'),
                      ),
                    );
                    return;
                  }

                  try {
                    final opened = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );

                    if (!context.mounted) return;

                    if (!opened) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open the PDF.'),
                        ),
                      );
                    }
                  } catch (error) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error opening PDF: $error'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text(
                  'OPEN NOTICE PDF',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2457C5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// STUDENT PROFILE SCREEN

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  Map<String, dynamic>? studentData;

  bool isLoading = true;
  String? profileError;

  @override
  void initState() {
    super.initState();
    fetchStudentProfile();
  }

  Future<void> fetchStudentProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('No student is logged in.');
      }

      final data = await Supabase.instance.client
          .from('students')
          .select()
          .eq('id', user.id)
          .single();

      if (!mounted) return;

      setState(() {
        studentData = data;
        isLoading = false;
        profileError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        profileError = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2457C5),
              ),
            )
          : profileError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Could not load profile:\n$profileError',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              profileError = null;
                            });
                            fetchStudentProfile();
                          },
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const CircleAvatar(
                        radius: 55,
                        backgroundColor: Color(0xFFE4ECFF),
                        child: Icon(
                          Icons.person,
                          size: 65,
                          color: Color(0xFF2457C5),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        studentData?['full_name'] ?? 'Student Name',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF18366F),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        studentData?['email'] ?? '',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      profileItem(
                        Icons.person_outline,
                        'Full Name',
                        studentData?['full_name'] ?? '',
                      ),
                      profileItem(
                        Icons.email_outlined,
                        'Email Address',
                        studentData?['email'] ?? '',
                      ),
                      profileItem(
                        Icons.school_outlined,
                        'Department',
                        studentData?['department'] ?? '',
                      ),
                      profileItem(
                        Icons.calendar_month,
                        'Academic Year',
                        studentData?['academic_year'] ?? '',
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await AuthService().logoutStudent();

                              if (!context.mounted) return;

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            } catch (error) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Logout failed: $error'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'LOGOUT',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget profileItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2457C5),
            size: 25,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// NOTIFICATIONS SCREEN

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];

  bool isLoading = true;
  bool isUpdating = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // LOAD NOTIFICATIONS FROM SUPABASE

  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        throw Exception('No student is logged in.');
      }

      final data = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('student_id', user.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        notifications = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  // MARK ONE NOTIFICATION AS READ

  Future<void> markAsRead(
    Map<String, dynamic> notification,
  ) async {
    if (notification['is_read'] == true) return;

    final user = Supabase.instance.client.auth.currentUser;
    final notificationId = notification['id'];

    if (user == null || notificationId == null) return;

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('student_id', user.id);

      if (!mounted) return;

      setState(() {
        notification['is_read'] = true;
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update notification: $error'),
        ),
      );
    }
  }

  // MARK ALL NOTIFICATIONS AS READ

  Future<void> markAllAsRead() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    setState(() {
      isUpdating = true;
    });

    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('student_id', user.id)
          .eq('is_read', false);

      if (!mounted) return;

      setState(() {
        for (final notification in notifications) {
          notification['is_read'] = true;
        }
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update notifications: $error'),
        ),
      );
    }
  }

  // GET ICON ACCORDING TO CATEGORY

  IconData getNotificationIcon(String category) {
    switch (category.toLowerCase()) {
      case 'exams':
        return Icons.menu_book;
      case 'events':
        return Icons.celebration;
      case 'holidays':
        return Icons.calendar_month;
      default:
        return Icons.notifications_active;
    }
  }

  // FORMAT DATE

  String formatDate(dynamic dateValue) {
    if (dateValue == null) return 'Date unavailable';

    final date = DateTime.tryParse(dateValue.toString());

    if (date == null) return dateValue.toString();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications
        .where((notification) => notification['is_read'] != true)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: unreadCount == 0 || isUpdating
                ? null
                : markAllAsRead,
            child: isUpdating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Mark all read',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                unreadCount == 0
                    ? 'You are all caught up!'
                    : 'You have $unreadCount unread notifications',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18366F),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2457C5),
                      ),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 45,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Could not load notifications.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 15),
                                ElevatedButton(
                                  onPressed: fetchNotifications,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : notifications.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.notifications_none,
                                    size: 65,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No notifications yet.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: fetchNotifications,
                                    child: const Text('Refresh'),
                                  ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchNotifications,
                              child: ListView.builder(
                                physics:
                                    const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notification =
                                      notifications[index];

                                  final isRead =
                                      notification['is_read'] == true;

                                  final title =
                                      (notification['title'] ?? '')
                                          .toString();

                                  final message =
                                      (notification['message'] ?? '')
                                          .toString();

                                  final category =
                                      (notification['category'] ??
                                              'General')
                                          .toString();

                                  final date = formatDate(
                                    notification['created_at'],
                                  );

                                  return Card(
                                    color: isRead
                                        ? Colors.white
                                        : const Color(0xFFE8EFFF),
                                    elevation: 1,
                                    margin: const EdgeInsets.only(
                                      bottom: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.all(14),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFD8E4FF),
                                        child: Icon(
                                          getNotificationIcon(category),
                                          color:
                                              const Color(0xFF2457C5),
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: TextStyle(
                                                fontWeight: isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          if (!isRead)
                                            Container(
                                              width: 9,
                                              height: 9,
                                              decoration:
                                                  const BoxDecoration(
                                                color:
                                                    Color(0xFF2457C5),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 7),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(message),
                                            const SizedBox(height: 8),
                                            Text(
                                              '$category • $date',
                                              style: const TextStyle(
                                                color:
                                                    Color(0xFF2457C5),
                                                fontSize: 12,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              isRead ? 'Read' : 'Unread',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isRead
                                                    ? Colors.grey
                                                    : const Color(
                                                        0xFF2457C5,
                                                      ),
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        markAsRead(notification);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
