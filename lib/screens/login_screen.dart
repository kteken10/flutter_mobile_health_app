import 'package:flutter/material.dart';
import 'package:flutter_flag_selector/flutter_flag_selector.dart';

import '../theme.dart';
import '../widgets/brand.dart';
import 'shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Compte de démonstration prérempli.
  final _phone = TextEditingController(text: '6 99 12 34 56');
  final _password = TextEditingController(text: 'demo1234');
  String _dialCode = '+237';
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_phone.text.trim().length < 6 || _password.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saisissez votre numéro et votre mot de passe.')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            const BrandMark(),
            const SizedBox(height: 24),
            const _Hero(),
            const SizedBox(height: 28),
            const Text(
              'Bon retour, docteur',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connectez-vous pour suivre vos patients et lancer une analyse.',
              style: TextStyle(fontSize: 15, color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            const _Label('Téléphone'),
            Row(
              children: [
                FlagSelector(
                  flagSelectorLanguageCode: 'fr',
                  flagSelectorInitialCountry: 'cm',
                  flagSelectorFlagWidth: 28,
                  flagSelectorFlagHeight: 20,
                  flagSelectorShowCountryName: false,
                  flagSelectorModalTitle: 'Choisir un pays',
                  flagSelectorSearchHintText: 'Rechercher un pays',
                  flagSelectorPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  flagSelectorDecoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  onFlagSelectorCountryChanged: (c) => setState(() => _dialCode = c.dialCode),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: Text(_dialCode,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _Label('Mot de passe'),
            TextField(
              controller: _password,
              obscureText: _obscure,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.muted),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Mot de passe oublié ?',
                    style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _signIn,
              child: _loading
                  ? const SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Se connecter'),
            ),
            const SizedBox(height: 40),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_user_outlined, size: 18, color: AppColors.muted),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Outil d\'aide au dépistage réservé aux professionnels de santé. '
                    'Il ne remplace pas un diagnostic médical.',
                    style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bandeau d'accueil : la promesse de l'app et la médecin.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 168),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF14B8A6), AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 0,
            top: 10,
            child: Image.asset('assets/images/doctor.png', fit: BoxFit.contain, alignment: Alignment.bottomCenter),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 34, 150, 34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Le dépistage clinique, expliqué.',
                    style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1.25)),
                SizedBox(height: 10),
                Text('5 pathologies couvertes',
                    style: TextStyle(color: Color(0xDDFFFFFF), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}
