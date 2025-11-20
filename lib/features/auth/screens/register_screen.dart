import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;
  
  int _currentStep = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      // Validate current step before moving forward
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      // Last step - register user
      _register();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personal Info
        if (_firstNameController.text.trim().isEmpty) {
          _showError('Please enter your first name');
          return false;
        }
        if (_lastNameController.text.trim().isEmpty) {
          _showError('Please enter your last name');
          return false;
        }
        if (_ageController.text.isNotEmpty) {
          final age = int.tryParse(_ageController.text);
          if (age == null || age < 1 || age > 120) {
            _showError('Please enter a valid age');
            return false;
          }
        }
        return true;
      case 1: // Account Details
        if (_emailController.text.trim().isEmpty) {
          _showError('Please enter your email');
          return false;
        }
        if (!EmailValidator.validate(_emailController.text.trim())) {
          _showError('Please enter a valid email');
          return false;
        }
        if (_passwordController.text.isEmpty) {
          _showError('Please enter your password');
          return false;
        }
        if (_passwordController.text.length < 6) {
          _showError('Password must be at least 6 characters');
          return false;
        }
        if (_confirmPasswordController.text != _passwordController.text) {
          _showError('Passwords do not match');
          return false;
        }
        return true;
      case 2: // Profile Photo (optional)
        return true;
      default:
        return false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'First Name',
          hint: 'Enter your first name',
          controller: _firstNameController,
          prefixIcon: Icon(
            PhosphorIcons.user(),
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Last Name',
          hint: 'Enter your last name',
          controller: _lastNameController,
          prefixIcon: Icon(
            PhosphorIcons.user(),
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Age (Optional)',
          hint: 'Enter your age',
          controller: _ageController,
          keyboardType: TextInputType.number,
          prefixIcon: Icon(
            PhosphorIcons.calendar(),
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            PhosphorIcons.envelope(),
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Password',
          hint: 'Enter your password',
          controller: _passwordController,
          isPassword: true,
          prefixIcon: Icon(
            PhosphorIcons.lock(),
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Confirm Password',
          hint: 'Confirm your password',
          controller: _confirmPasswordController,
          isPassword: true,
          prefixIcon: Icon(
            PhosphorIcons.lock(),
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add a profile photo',
          style: AppTheme.titleStyle.copyWith(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'This is optional - you can skip this step',
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.image(PhosphorIconsStyle.bold),
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap to select photo',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                        size: 64,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Photo selected',
                        style: AppTheme.bodyStyle.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedImage!.name,
                        style: AppTheme.captionStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: AppTheme.bodyStyle,
            ),
            GestureDetector(
              onTap: () => context.go('/login'),
              child: Text(
                'Sign In',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        print("RegisterScreen: Starting registration...");
        
        final success = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          age: _ageController.text.isEmpty ? null : int.tryParse(_ageController.text),
          imagePath: _selectedImage?.path,
        );

        print("RegisterScreen: Registration result: $success");

        if (success && mounted) {
          // Navigate to home (regular users only)
          print("RegisterScreen: Navigating to home...");
          context.go('/home');
        } else if (mounted) {
          // Show error message
          final errorMessage = authProvider.error ?? 'Registration failed';
          print("RegisterScreen: Registration failed - $errorMessage");
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } catch (e) {
        print("RegisterScreen: Caught exception - $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.accentGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        PhosphorIcons.filmStrip(),
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Join Film Manager',
                      style: AppTheme.headlineStyle.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Step ${_currentStep + 1} of 3',
                      style: AppTheme.subtitleStyle.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Stepper Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: AppTheme.primaryColor,
                        ),
                      ),
                      child: Stepper(
                        currentStep: _currentStep,
                        onStepContinue: _onStepContinue,
                        onStepCancel: _onStepCancel,
                        controlsBuilder: (context, details) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return CustomButton(
                                        text: _currentStep == 2 ? 'Create Account' : 'Continue',
                                        onPressed: details.onStepContinue,
                                        isLoading: authProvider.isLoading,
                                      );
                                    },
                                  ),
                                ),
                                if (_currentStep > 0) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: details.onStepCancel,
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        side: BorderSide(color: AppTheme.primaryColor),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'Back',
                                        style: AppTheme.bodyStyle.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                        steps: [
                          // Step 1: Personal Information
                          Step(
                            title: const Text('Personal Info'),
                            isActive: _currentStep >= 0,
                            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                            content: _buildPersonalInfoStep(),
                          ),
                          // Step 2: Account Details
                          Step(
                            title: const Text('Account Details'),
                            isActive: _currentStep >= 1,
                            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                            content: _buildAccountDetailsStep(),
                          ),
                          // Step 3: Profile Photo
                          Step(
                            title: const Text('Profile Photo'),
                            isActive: _currentStep >= 2,
                            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                            content: _buildProfilePhotoStep(),
                          ),
                        ],
                      ),
                    ),
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
