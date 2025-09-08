import 'package:flutter/material.dart';
import '../model/patient.dart';
import '../service/email_service.dart';


class AddPatientModal extends StatefulWidget {
  final Function(Patient) onPatientAdded;
  final String doctorName;

  const AddPatientModal({
    super.key, 
    required this.onPatientAdded,
    required this.doctorName,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddPatientModalState createState() => _AddPatientModalState();
}

class _AddPatientModalState extends State<AddPatientModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidDate(String date) {
    return RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(date);
  }

  Future<void> _sendWelcomeEmail(String email, String name) async {
    try {
      final emailService = EmailService(
        smtpServer: 'smtp.gmail.com',
        smtpUsername: 'tchokoutef@gmail.com',
        smtpPassword: 'wqex wwni azjo fqnw',
        senderEmail: 'tchokoutef@gmail.com',
        senderName: 'Clinique Médicale AI',
      );

      await emailService.sendPatientWelcomeEmail(
        recipientEmail: email,
        patientName: name,
        patientId: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorName: widget.doctorName,
      );
    } catch (e) {
      // Ne pas propager l'erreur pour ne pas bloquer l'ajout du patient
      debugPrint('Erreur d\'envoi d\'email: $e');
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 132, 177, 254)),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_add_alt_1_rounded, 
                size: 50, 
                color: Color.fromARGB(255, 132, 177, 254)),
              const SizedBox(height: 16),
              const Text(
                "Ajouter un Patient",
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Veuillez remplir les informations ci-dessous",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Nom du patient
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Nom complet", Icons.person_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer le nom du patient';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date de naissance
              TextFormField(
                controller: _ageController,
                decoration: _inputDecoration("Date de naissance (jj/mm/aaaa)", Icons.calendar_today),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer la date de naissance';
                  }
                  if (!_isValidDate(value)) {
                    return 'Format invalide (jj/mm/aaaa)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("Adresse email", Icons.email),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une adresse email';
                  }
                  if (!_isValidEmail(value)) {
                    return 'Adresse email invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      "ANNULER",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 132, 177, 254),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading 
                        ? null 
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              
                              try {
                                final newPatient = Patient(
                                  name: _nameController.text.trim(),
                                  age: _ageController.text.trim(),
                                  status: _emailController.text.trim(),
                                  imageUrl: 'assets/user-18.jpg',
                                );
                                
                                // Envoyer l'email de bienvenue
                                await _sendWelcomeEmail(
                                  _emailController.text.trim(),
                                  _nameController.text.trim(),
                                );
                                
                                widget.onPatientAdded(newPatient);
                                Navigator.of(context).pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Erreur: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "AJOUTER",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}