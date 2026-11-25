
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/pdf_text_service.dart';

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
                  initialValue: selectedDepartment,
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
                  initialValue: selectedYear,
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

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> logout(BuildContext context) async {
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
        SnackBar(content: Text('Logout failed: $error')),
      );
    }
  }

  Future<void> openAddNotice(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNoticeScreen(),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notice added successfully!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 25),
              const Icon(
                Icons.admin_panel_settings,
                size: 85,
                color: Color(0xFF2457C5),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome, Admin!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18366F),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Manage your college notices from here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Notice Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF18366F),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.post_add,
                        size: 45,
                        color: Color(0xFF2457C5),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Add a New Notice',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Publish important college announcements, '
                        'exam schedules, events and holidays.',
                        style: TextStyle(
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => openAddNotice(context),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'ADD NEW NOTICE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2457C5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
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
  String detectCategory(String text) {
  final content = text.toLowerCase();

  if (content.contains('exam') ||
      content.contains('examination') ||
      content.contains('result') ||
      content.contains('timetable')) {
    return 'Examination';
  }

  if (content.contains('placement') ||
      content.contains('internship') ||
      content.contains('job') ||
      content.contains('recruitment')) {
    return 'Placement';
  }

  if (content.contains('event') ||
      content.contains('fest') ||
      content.contains('workshop') ||
      content.contains('seminar')) {
    return 'Events';
  }

  if (content.contains('assignment') ||
      content.contains('lecture') ||
      content.contains('class') ||
      content.contains('academic')) {
    return 'Academics';
  }

  return 'General';
}
  DateTime? selectedDate;

  PlatformFile? selectedPdf;
  String extractedPdfText = '';
  bool isLoading = false;

  final List<String> categories = [
    'Examination',
    'Placement',
    'Events',
    'Academics',
    'General',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // SELECT PDF FROM DEVICE

  
Future<void> choosePdf() async {
  try {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (file == null) return;

    final pdfBytes = await file.readAsBytes();

    final extractedText =
        PdfTextService.extractText(pdfBytes);

    if (!mounted) return;

    setState(() {
      selectedPdf = file;
      extractedPdfText = extractedText;

      if (descriptionController.text.trim().isEmpty &&
          extractedText.trim().isNotEmpty) {
        descriptionController.text = extractedText;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          extractedText.trim().isEmpty
              ? 'PDF selected, but no readable text was found.'
              : 'PDF selected and text extracted successfully!',
        ),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not process PDF: $error'),
      ),
    );
  }
}


  // SELECT NOTICE DATE

  Future<void> chooseDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // UPLOAD PDF AND PUBLISH NOTICE

  Future<void> saveNotice() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a notice date.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? pdfUrl;

      // UPLOAD SELECTED PDF TO SUPABASE STORAGE

      if (selectedPdf != null) {
        final pdfPath =
            '${DateTime.now().millisecondsSinceEpoch}.pdf';

        await Supabase.instance.client.storage
            .from('notice-pdfs')
            .uploadBinary(
              pdfPath,
              await selectedPdf!.readAsBytes(),
              fileOptions: const FileOptions(
                contentType: 'application/pdf',
                upsert: false,
              ),
            );

        // GET PUBLIC PDF URL

        pdfUrl = Supabase.instance.client.storage
            .from('notice-pdfs')
            .getPublicUrl(pdfPath);
      }

      // SAVE NOTICE DETAILS AND PDF URL IN DATABASE
      final detectedCategory = detectCategory(
  '${titleController.text} ${descriptionController.text}',
);

debugPrint('NOTICE TITLE: ${titleController.text}');
debugPrint('DETECTED CATEGORY: $detectedCategory');
      await Supabase.instance.client.from('notices').insert({
        'title': titleController.text.trim(),
        'category': detectedCategory,
        'description': descriptionController.text.trim(),
        'notice_date':
            '${selectedDate!.year.toString().padLeft(4, '0')}-'
            '${selectedDate!.month.toString().padLeft(2, '0')}-'
            '${selectedDate!.day.toString().padLeft(2, '0')}',
        'pdf_url': pdfUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notice and PDF published successfully!'),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not publish notice: $error'),
        ),
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
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Add New Notice'),
        backgroundColor: const Color(0xFF2457C5),
        foregroundColor: Colors.white,
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
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
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
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
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
                'Notice Date',
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
                'Attach Notice PDF',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isLoading ? null : choosePdf,
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                ),
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
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'PDF selected successfully',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() {
                                selectedPdf = null;
                              });
                            },
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : saveNotice,
                  icon: const Icon(Icons.publish),
                  label: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'PUBLISH NOTICE',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
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
            const SizedBox(height: 25),
            Text(
              notice['category'] ?? 'General',
              style: const TextStyle(
                color: Color(0xFF2457C5),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              notice['title'] ?? 'Notice',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF18366F),
              ),
            ),
            const SizedBox(height: 18),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Important Date',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (notice['date'] == null ||
                                  notice['date']!.isEmpty)
                              ? 'Not specified'
                              : notice['date']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
                  fontSize: 16,
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
