// // lib/screens/ogrenci/ogrenci_profile.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import '../../core/models/profile_model.dart';
// import '../../core/services/profile_service.dart';
// import '../../core/firebase/auth_service.dart';
// import '../../core/firebase/storage_service.dart';
// import '../../widgets/custom_text_field.dart';
// import '../../widgets/gradient_button.dart';
//
// class OgrenciProfile extends StatefulWidget {
//   const OgrenciProfile({super.key});
//
//   @override
//   _OgrenciProfileState createState() => _OgrenciProfileState();
// }
//
// class _OgrenciProfileState extends State<OgrenciProfile> {
//   final ProfileService _profileService = ProfileService();
//   final AuthService _authService = AuthService();
//   final StorageService _storageService = StorageService();
//   final ImagePicker _imagePicker = ImagePicker();
//
//   late User? _currentUser;
//   ProfileModel? _profile;
//   bool _isLoading = true;
//   bool _isEditing = false;
//   File? _selectedImage;
//   String? _imageUrl;
//
//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _studentNoController = TextEditingController();
//   final TextEditingController _universityController = TextEditingController();
//   final TextEditingController _departmentController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _skillsController = TextEditingController();
//   final TextEditingController _aboutController = TextEditingController();
//   final TextEditingController _githubController = TextEditingController();
//   final TextEditingController _linkedinController = TextEditingController();
//   final TextEditingController _portfolioController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }
//
//   Future<void> _loadProfile() async {
//     setState(() => _isLoading = true);
//
//     try {
//       _currentUser = _authService.getCurrentUser();
//       if (_currentUser == null) return;
//
//       // 1) جرّب يجيب Profile من profiles
//       _profile = await _profileService.getProfileByUserId(_currentUser!.uid);
//
//       if (_profile != null) {
//         _fillControllers();
//         return;
//       }
//
//       // 2) إذا ما لقى profile -> جيب البيانات من users وعبّي الفورم
//       final userData = await _authService.getUserData(_currentUser!.uid);
//
//       if (userData != null) {
//         _nameController.text = userData.name;
//         _emailController.text = userData.email;
//         _studentNoController.text = userData.studentNo ?? '';
//         _universityController.text = userData.university ?? '';
//         _departmentController.text = userData.department ?? '';
//         _phoneController.text = userData.phone ?? '';
//         _skillsController.text = (userData.skills ?? []).join(', ');
//         _aboutController.text = userData.bio ?? ''; // أو خليها فاضية
//         _imageUrl = null;
//       } else {
//         // fallback أخير من FirebaseAuth
//         _nameController.text = _currentUser!.displayName ?? '';
//         _emailController.text = _currentUser!.email ?? '';
//       }
//     } catch (e) {
//       print('Profil yükleme hatası: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//
//   void _fillControllers() {
//     if (_profile == null) return;
//
//     _nameController.text = _profile!.name;
//     _emailController.text = _profile!.email;
//     _studentNoController.text = _profile!.studentNo ?? '';
//     _universityController.text = _profile!.university ?? '';
//     _departmentController.text = _profile!.department ?? '';
//     _phoneController.text = _profile!.phone ?? '';
//     _skillsController.text = _profile!.formattedSkills;
//     _aboutController.text = _profile!.about ?? '';
//     _githubController.text = _profile!.githubUrl ?? '';
//     _linkedinController.text = _profile!.linkedinUrl ?? '';
//     _portfolioController.text = _profile!.portfolioUrl ?? '';
//     _imageUrl = _profile!.profileImageUrl;
//   }
//
//   Future<void> _pickImage() async {
//     final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//
//       // Upload image
//       await _uploadImage();
//     }
//   }
//
//   Future<void> _uploadImage() async {
//     if (_selectedImage == null || _currentUser == null) return;
//
//     try {
//       setState(() => _isLoading = true);
//
//       final imageUrl = await _storageService.uploadProfileImage(
//         _selectedImage!,
//         _currentUser!.uid,
//         true, // isStudent
//       );
//
//       // Update profile with new image URL
//       await _profileService.updateProfileImage(
//         _currentUser!.uid,
//         imageUrl,
//         true,
//       );
//
//       setState(() {
//         _imageUrl = imageUrl;
//         _selectedImage = null;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Profil resmi güncellendi'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Resim yükleme hatası: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _saveProfile() async {
//     if (_currentUser == null) return;
//
//     try {
//       setState(() => _isLoading = true);
//
//       // Create updated profile
//       final updatedProfile = ProfileModel(
//         id: _profile?.id,
//         userId: _currentUser!.uid,
//         email: _emailController.text.trim(),
//         name: _nameController.text.trim(),
//         role: 'ogrenci',
//         createdAt: _profile?.createdAt ?? DateTime.now(),
//
//         // Student fields
//         studentNo: _studentNoController.text.trim(),
//         university: _universityController.text.trim(),
//         department: _departmentController.text.trim(),
//         phone: _phoneController.text.trim(),
//         skills: _skillsController.text.isNotEmpty
//             ? _skillsController.text.split(',').map((e) => e.trim()).toList()
//             : [],
//         about: _aboutController.text.trim(),
//         profileImageUrl: _imageUrl,
//         githubUrl: _githubController.text.trim(),
//         linkedinUrl: _linkedinController.text.trim(),
//         portfolioUrl: _portfolioController.text.trim(),
//       );
//
//       // Update profile
//       await _profileService.updateProfile(updatedProfile);
//
//       setState(() {
//         _profile = updatedProfile;
//         _isEditing = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Profil başarıyla güncellendi'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Güncelleme hatası: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   Widget _buildProfileHeader() {
//     return Column(
//       children: [
//         // Profile Image
//         GestureDetector(
//           onTap: _isEditing ? _pickImage : null,
//           child: Stack(
//             children: [
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(color: const Color(0xFF1ABC9C), width: 3),
//                 ),
//                 child: ClipOval(
//                   child: _imageUrl != null && _imageUrl!.isNotEmpty
//                       ? Image.network(
//                     _imageUrl!,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return const Icon(
//                         Icons.person,
//                         size: 60,
//                         color: Color(0xFF1ABC9C),
//                       );
//                     },
//                   )
//                       : _selectedImage != null
//                       ? Image.file(
//                     _selectedImage!,
//                     fit: BoxFit.cover,
//                   )
//                       : const Icon(
//                     Icons.person,
//                     size: 60,
//                     color: Color(0xFF1ABC9C),
//                   ),
//                 ),
//               ),
//               if (_isEditing)
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF1ABC9C),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.camera_alt,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//
//         // Name and Info
//         Text(
//           _profile?.name ?? 'Öğrenci',
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         const SizedBox(height: 8),
//
//         Text(
//           _profile?.university ?? 'Üniversite',
//           style: const TextStyle(
//             fontSize: 16,
//             color: Color(0xFF7F8C8D),
//           ),
//         ),
//         Text(
//           '${_profile?.department ?? 'Bölüm'} - ${_profile?.studentNo ?? 'Öğrenci No'}',
//           style: const TextStyle(
//             fontSize: 14,
//             color: Color(0xFF7F8C8D),
//           ),
//         ),
//
//         // Profile Completion
//         const SizedBox(height: 20),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Profil Tamamlanma Oranı',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2C3E50),
//                     ),
//                   ),
//                   Text(
//                     '${_profile?.completionPercentage ?? 0}%',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1ABC9C),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               LinearProgressIndicator(
//                 value: (_profile?.completionPercentage ?? 0) / 100,
//                 backgroundColor: const Color(0xFFECF0F1),
//                 color: const Color(0xFF1ABC9C),
//                 minHeight: 8,
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEditButton() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 20),
//       child: GradientButton(
//         text: _isEditing ? 'KAYDET' : 'PROFİLİ DÜZENLE',
//         onPressed: () {
//           if (_isEditing) {
//             _saveProfile();
//           } else {
//             setState(() => _isEditing = true);
//           }
//         },
//         isLoading: _isLoading,
//         gradient: LinearGradient(
//           colors: _isEditing
//               ? [const Color(0xFF1ABC9C), const Color(0xFF16A085)]
//               : [const Color(0xFF3498DB), const Color(0xFF2980B9)],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCancelButton() {
//     if (!_isEditing) return const SizedBox();
//
//     return TextButton(
//       onPressed: () {
//         setState(() {
//           _isEditing = false;
//           _fillControllers(); // Reset to original values
//         });
//       },
//       child: const Text(
//         'İptal',
//         style: TextStyle(
//           color: Colors.red,
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileForm() {
//     if (!_isEditing) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // View Mode - Display only
//           _buildInfoCard(
//             title: 'Kişisel Bilgiler',
//             items: [
//               _buildInfoItem(icon: Icons.email, label: 'E-posta', value: _profile?.email),
//               _buildInfoItem(icon: Icons.phone, label: 'Telefon', value: _profile?.phone),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           _buildInfoCard(
//             title: 'Üniversite Bilgileri',
//             items: [
//               _buildInfoItem(icon: Icons.numbers, label: 'Öğrenci No', value: _profile?.studentNo),
//               _buildInfoItem(icon: Icons.school, label: 'Üniversite', value: _profile?.university),
//               _buildInfoItem(icon: Icons.menu_book, label: 'Bölüm', value: _profile?.department),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           _buildInfoCard(
//             title: 'Yetenekler',
//             items: [
//               _buildInfoItem(
//                 icon: Icons.code,
//                 label: 'Yetenekler',
//                 value: _profile?.formattedSkills,
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           if (_profile?.about?.isNotEmpty == true)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Hakkımda',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     _profile!.about!,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF7F8C8D),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       );
//     }
//
//     // Edit Mode - Form
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // Personal Info
//           const Text(
//             '📝 Kişisel Bilgiler',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           CustomTextField(
//             controller: _nameController,
//             label: 'Ad Soyad',
//             prefixIcon: Icons.person,
//             isRequired: true,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _emailController,
//             label: 'E-posta',
//             prefixIcon: Icons.email,
//             keyboardType: TextInputType.emailAddress,
//             isRequired: true,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _phoneController,
//             label: 'Telefon',
//             prefixIcon: Icons.phone,
//             keyboardType: TextInputType.phone,
//           ),
//
//           const SizedBox(height: 30),
//
//           // University Info
//           const Text(
//             '🎓 Üniversite Bilgileri',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           CustomTextField(
//             controller: _studentNoController,
//             label: 'Öğrenci No',
//             prefixIcon: Icons.numbers,
//             keyboardType: TextInputType.number,
//             isRequired: true,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _universityController,
//             label: 'Üniversite',
//             prefixIcon: Icons.school,
//             isRequired: true,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _departmentController,
//             label: 'Bölüm',
//             prefixIcon: Icons.menu_book,
//             isRequired: true,
//           ),
//
//           const SizedBox(height: 30),
//
//           // Skills
//           const Text(
//             '💻 Yetenekler',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           CustomTextField(
//             controller: _skillsController,
//             label: 'Yetenekler (virgülle ayırın)',
//             prefixIcon: Icons.code,
//             maxLines: 3,
//           ),
//
//           const SizedBox(height: 30),
//
//           // About
//           const Text(
//             '📖 Hakkımda',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           CustomTextField(
//             controller: _aboutController,
//             label: 'Kendinizi tanıtın',
//             prefixIcon: Icons.info,
//             maxLines: 5,
//           ),
//
//           const SizedBox(height: 30),
//
//           // Social Links
//           const Text(
//             '🔗 Sosyal Bağlantılar',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           CustomTextField(
//             controller: _githubController,
//             label: 'GitHub URL',
//             prefixIcon: Icons.code,
//             keyboardType: TextInputType.url,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _linkedinController,
//             label: 'LinkedIn URL',
//             prefixIcon: Icons.work,
//             keyboardType: TextInputType.url,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _portfolioController,
//             label: 'Portfolio URL',
//             prefixIcon: Icons.language,
//             keyboardType: TextInputType.url,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoCard({
//     required String title,
//     required List<Widget> items,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: Column(
//             children: items,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildInfoItem({
//     required IconData icon,
//     required String label,
//     required String? value,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Icon(icon, color: const Color(0xFF1ABC9C), size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF95A5A6),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value ?? 'Belirtilmemiş',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF2C3E50),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Profilim'),
//         backgroundColor: const Color(0xFF1ABC9C),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           if (_isEditing) _buildCancelButton(),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(
//         child: CircularProgressIndicator(color: Color(0xFF1ABC9C)),
//       )
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             _buildProfileHeader(),
//             _buildEditButton(),
//             _buildProfileForm(),
//             const SizedBox(height: 40),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _studentNoController.dispose();
//     _universityController.dispose();
//     _departmentController.dispose();
//     _phoneController.dispose();
//     _skillsController.dispose();
//     _aboutController.dispose();
//     _githubController.dispose();
//     _linkedinController.dispose();
//     _portfolioController.dispose();
//     super.dispose();
//   }
// }