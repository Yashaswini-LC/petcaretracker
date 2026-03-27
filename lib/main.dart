import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'services/settings_service.dart';
import 'auth_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SettingsService.init();
  }
  runApp(const MyApp());
}

class Pet {
  final String name;
  final String type;
  List<Map<String, String>> activities;

  Pet(this.name, this.type) : activities = [];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Care Tracker',
      theme: lightTheme(),
      darkTheme: darkTheme(),
themeMode: ThemeMode.system,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const HomePage() : const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignup = false;
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await AuthService.login(_emailController.text.trim());
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: RotationTransition(
                      turns: _logoController,
                      child: Lottie.asset(
                        'assets/lottie/pet_dance.json',
                        width: 120,
                        height: 120,
                        repeat: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isSignup ? 'Create Account' : 'Welcome Back',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignup ? 'Create your pet care account' : 'Sign in to your account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter email';
                      if (!value.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter password';
                      if (value.length < 6) return 'Password must be 6+ chars';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _authenticate,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_isSignup ? 'Sign Up' : 'Login'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() => _isSignup = !_isSignup);
                      _emailController.clear();
                      _passwordController.clear();
                    },
                    child: Text(_isSignup ? 'Already have account? Login' : "Don't have account? Sign Up"),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Pet> pets = [];
  String searchText = '';
  bool isDark = true;
  late AnimationController _petController;
  late Animation<double> _petAnimation;

  void toggleTheme() => setState(() => isDark = !isDark);

  @override
  void initState() {
    super.initState();
    _petController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _petAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _petController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _petController.dispose();
    super.dispose();
  }

  void addPet(String name, String type) {
    setState(() => pets.add(Pet(name.trim(), type.trim())));
  }

  void addActivity(int index, String activity) {
    setState(() => pets[index].activities.add({
      'activity': activity,
      'date': DateTime.now().toString().substring(0, 16)
    }));
  }

  void deletePet(int index) {
    setState(() => pets.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final filteredPets = pets.where((p) => p.name.toLowerCase().contains(searchText.toLowerCase())).toList();
    final totalActivities = pets.fold<int>(0, (sum, pet) => sum + pet.activities.length);

    return Scaffold(
appBar: AppBar(
        title: const Text('My Pets'),
        elevation: 0,
        actions: [
  IconButton(
            icon: Icon(isDark ? Icons.brightness_low : Icons.brightness_high),
            onPressed: toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _petAnimation,
                  child: RotationTransition(
                    turns: _petController,
                    child: Lottie.asset(
                      'assets/lottie/pet_dance.json',
                      width: 60,
                      height: 60,
                      repeat: true,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCard(label: 'Pets', value: pets.length.toString()),
                      _StatCard(label: 'Activities', value: totalActivities.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search pets...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) => setState(() => searchText = val),
            ),
          ),
          Expanded(
            child: filteredPets.isEmpty
                ? const Center(child: Text('No Pets Yet - Add your first pet!'))
                : ListView.builder(
                    itemCount: filteredPets.length,

                    itemBuilder: (context, index) {
                      final pet = filteredPets[index];
                      final realIndex = pets.indexOf(pet);
                      return ExpansionTile(
                        title: Text(pet.name),
                        subtitle: Text(pet.type),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deletePet(realIndex),
                        ),
                        children: [
                          ...pet.activities.map((a) => ListTile(
                            leading: const Icon(Icons.check, color: Colors.green),
                            title: Text(a['activity']!),
                            subtitle: Text(a['date']!),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.restaurant, size: 16),
                                  label: const Text('Feed'),
                                  onPressed: () => addActivity(realIndex, 'Feeding'),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.medical_services, size: 16),
                                  label: const Text('Vaccine'),
                                  onPressed: () => addActivity(realIndex, 'Vaccination'),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.local_hospital, size: 16),
                                  label: const Text('Vet Visit'),
                                  onPressed: () => addActivity(realIndex, 'Vet Visit'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },

                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPetDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Pet'),
      ),
    );
  }

  void _showAddPetDialog(BuildContext context) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Pet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Pet Name'),
            ),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Type (Dog/Cat...)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty && typeController.text.trim().isNotEmpty) {
                addPet(nameController.text, typeController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Pet'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label),
        ],
      ),
    );
  }
}

