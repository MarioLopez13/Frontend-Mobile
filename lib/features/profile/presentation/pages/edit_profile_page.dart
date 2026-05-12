import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpayut_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smartpayut_mobile/shared/theme/app_colors.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _idController;
  late final TextEditingController _cityController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final user = ref.read(authControllerProvider);

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _idController = TextEditingController(text: user?.documentId ?? '');
    _cityController = TextEditingController(text: user?.city ?? 'Quito');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _isSaving = true;
  });

  final error = await ref.read(authControllerProvider.notifier).updateLocalProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        documentId: _idController.text,
        city: _cityController.text,
      );

  if (!mounted) {
    return;
  }

  setState(() {
    _isSaving = false;
  });

  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Datos actualizados correctamente.'),
    ),
  );

  Navigator.of(context).pop();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandDark, AppColors.brand],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.manage_accounts_outlined,
                  color: Colors.white,
                  size: 34,
                ),
                SizedBox(height: 14),
                Text(
                  'Datos personales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Actualiza la información visible del usuario final. Este flujo queda preparado para conexión backend.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if ((value ?? '').trim().isEmpty) {
                          return 'Ingresa el nombre completo.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isEmpty || !text.contains('@')) {
                          return 'Ingresa un correo válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                        counterText: '',
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isNotEmpty && text.length != 10) {
                          return 'El teléfono debe tener 10 dígitos.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: 'Cédula',
                        prefixIcon: Icon(Icons.badge_outlined),
                        counterText: '',
                      ),
                      validator: (value) {
                        final text = (value ?? '').trim();
                        if (text.isNotEmpty && text.length != 10) {
                          return 'La cédula debe tener 10 dígitos.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving ? 'Guardando...' : 'Guardar cambios',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}