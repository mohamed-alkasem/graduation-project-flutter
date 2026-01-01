// // lib/screens/sirket/sirket_profile.dart
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import '../../core/models/profile_model.dart' show ProfileModel;
// import '../../core/services/profile_service.dart';
// import '../../core/firebase/auth_service.dart';
// import '../../core/firebase/storage_service.dart';
// import '../../widgets/custom_text_field.dart';
// import '../../widgets/gradient_button.dart';
//
// class SirketProfile extends StatefulWidget {
//   const SirketProfile({super.key});
//
//   @override
//   _SirketProfileState createState() => _SirketProfileState();
// }
//
// class _SirketProfileState extends State<SirketProfile> {
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
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _contactPersonController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _sectorController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _websiteController = TextEditingController();
//   final TextEditingController _taxNoController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//
//   // Sectors List
//   final List<String> _sectors = [
//     'Teknoloji',
//     'Finans',
//     'Sağlık',
//     'Eğitim',
//     'Üretim',
//     'Perakende',
//     'Turizm',
//     'Enerji',
//     'İnşaat',
//     'Diğer'
//   ];
//   String? _selectedSector;
//
//   // Company Sizes
//   final List<String> _companySizes = [
//     'Küçük (1-50 çalışan)',
//     'Orta (51-250 çalışan)',
//     'Büyük (250+ çalışan)'
//   ];
//   String? _selectedCompanySize;
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
//
//       if (_currentUser != null) {
//         _profile = await _profileService.getProfileByUserId(_currentUser!.uid);
//
//         if (_profile != null) {
//           _fillControllers();
//         }
//       }
//     } catch (e) {
//       // ignore: avoid_print
//       print('Profil yükleme hatası: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _fillControllers() {
//     if (_profile == null) return;
//
//     _companyNameController.text = _profile!.companyName ?? '';
//     _contactPersonController.text = _profile!.name;
//     _emailController.text = _profile!.email;
//     _phoneController.text = _profile!.companyPhone ?? '';
//     _sectorController.text = _profile!.sector ?? '';
//     _addressController.text = _profile!.address ?? '';
//     _websiteController.text = _profile!.website ?? '';
//     _taxNoController.text = _profile!.taxNo ?? '';
//     _descriptionController.text = _profile!.companyDescription ?? '';
//     _selectedSector = _profile!.sector;
//     _selectedCompanySize = _profile!.companySize;
//     _imageUrl = _profile!.companyLogoUrl;
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
//         false, // isStudent = false
//       );
//
//       // Update profile with new image URL
//       await _profileService.updateProfileImage(
//         _currentUser!.uid,
//         imageUrl,
//         false,
//       );
//
//       setState(() {
//         _imageUrl = imageUrl;
//         _selectedImage = null;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Şirket logosu güncellendi'),
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
//       final updatedProfile = ProfileModel(
//         id: _profile?.id,
//         userId: _currentUser!.uid,
//         email: _emailController.text.trim(),
//         name: _contactPersonController.text.trim(),
//         role: 'sirket',
//         createdAt: _profile?.createdAt ?? DateTime.now(),
//
//         // Company fields
//         companyName: _companyNameController.text.trim(),
//         sector: _selectedSector ?? '',
//         companyPhone: _phoneController.text.trim(),
//         address: _addressController.text.trim(),
//         website: _websiteController.text.trim(),
//         taxNo: _taxNoController.text.trim(),
//         contactPerson: _contactPersonController.text.trim(),
//         companyLogoUrl: _imageUrl,
//         companyDescription: _descriptionController.text.trim(),
//         companySize: _selectedCompanySize,
//         status: _profile?.status ?? 'pending',
//
//         // ✅ إذا عندك هالحقول بالموديل وخايف تروح قيمتها أثناء الحفظ:
//         // adminEmail: _profile?.adminEmail,
//         // rejectionReason: _profile?.rejectionReason,
//       );
//
//       await _profileService.updateProfile(updatedProfile);
//
//       setState(() {
//         _profile = updatedProfile;
//         _isEditing = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Şirket profili başarıyla güncellendi'),
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
//   // ✅ الهيدر (Logo + اسم + sektor + kişi) + ✅ Status Card الجديدة
//   Widget _buildProfileHeader() {
//     return Column(
//       children: [
//         // Company Logo
//         GestureDetector(
//           onTap: _isEditing ? _pickImage : null,
//           child: Stack(
//             children: [
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: const Color(0xFFE74C3C), width: 3),
//                   color: Colors.white,
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(16),
//                   child: _imageUrl != null && _imageUrl!.isNotEmpty
//                       ? Image.network(
//                     _imageUrl!,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return const Icon(
//                         Icons.business,
//                         size: 60,
//                         color: Color(0xFFE74C3C),
//                       );
//                     },
//                   )
//                       : _selectedImage != null
//                       ? Image.file(
//                     _selectedImage!,
//                     fit: BoxFit.cover,
//                   )
//                       : const Icon(
//                     Icons.business,
//                     size: 60,
//                     color: Color(0xFFE74C3C),
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
//                       color: Color(0xFFE74C3C),
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
//         // Company Name and Info
//         Text(
//           _profile?.companyName ?? 'Şirket Adı',
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         const SizedBox(height: 8),
//
//         Text(
//           _profile?.sector ?? 'Sektör',
//           style: const TextStyle(
//             fontSize: 16,
//             color: Color(0xFF7F8C8D),
//           ),
//         ),
//         Text(
//           _profile?.contactPerson ?? 'Yetkili Kişi',
//           style: const TextStyle(
//             fontSize: 14,
//             color: Color(0xFF7F8C8D),
//           ),
//         ),
//
//         const SizedBox(height: 20),
//
//         // ✅ Status Card الجديدة
//         _buildStatusCard(),
//       ],
//     );
//   }
//
//   // ✅ الدالة الجديدة (Status Card)
//   Widget _buildStatusCard() {
//     String status = _profile?.status ?? 'pending';
//     Color statusColor;
//     String statusText;
//     String statusDescription;
//
//     switch (status) {
//       case 'approved':
//       case 'active':
//         statusColor = Colors.green;
//         statusText = 'Onaylandı';
//         statusDescription = 'Hesabınız aktif olarak kullanılabilir.';
//         break;
//       case 'rejected':
//         statusColor = Colors.red;
//         statusText = 'Reddedildi';
//         statusDescription =
//             _profile?.rejectionReason ?? 'Yönetici tarafından reddedildi.';
//         break;
//       case 'pending_approval':
//         statusColor = Colors.orange;
//         statusText = 'Yönetici Onayı Bekliyor';
//         statusDescription = 'Hesabınız yönetici tarafından inceleniyor.';
//         break;
//       default:
//         statusColor = Colors.orange;
//         statusText = 'Onay Bekliyor';
//         statusDescription = 'Hesabınız yönetici onayı bekliyor.';
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: statusColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: statusColor),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 _getStatusIconByString(status),
//                 color: statusColor,
//                 size: 24,
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   'Hesap Durumu: $statusText',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: statusColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Text(
//             statusDescription,
//             style: TextStyle(color: Colors.grey[700]),
//           ),
//           if (_profile?.adminEmail != null) ...[
//             const SizedBox(height: 8),
//             Text(
//               'Yönetici: ${_profile!.adminEmail}',
//               style: const TextStyle(
//                 fontSize: 12,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   // ✅ icon حسب status string (للدالة الجديدة)
//   IconData _getStatusIconByString(String status) {
//     switch (status) {
//       case 'approved':
//       case 'active':
//         return Icons.verified;
//       case 'rejected':
//         return Icons.cancel;
//       default:
//         return Icons.pending;
//     }
//   }
//
//   // (القديمة) إذا بتستخدمها بمكان تاني خليا
//   IconData _getStatusIcon() {
//     switch (_profile?.status) {
//       case 'approved':
//         return Icons.verified;
//       case 'rejected':
//         return Icons.cancel;
//       default:
//         return Icons.pending;
//     }
//   }
//
//   Color _getStatusColor() {
//     switch (_profile?.status) {
//       case 'approved':
//         return const Color(0xFF2ECC71);
//       case 'rejected':
//         return const Color(0xFFE74C3C);
//       default:
//         return const Color(0xFFF39C12);
//     }
//   }
//
//   String _getStatusText() {
//     switch (_profile?.status) {
//       case 'approved':
//         return 'Onaylandı';
//       case 'rejected':
//         return 'Reddedildi';
//       default:
//         return 'Onay Bekliyor';
//     }
//   }
//
//   String _getStatusDescription() {
//     switch (_profile?.status) {
//       case 'approved':
//         return 'Şirket hesabınız aktif olarak kullanılabilir.';
//       case 'rejected':
//         return 'Hesabınız reddedildi. Detaylar için iletişime geçin.';
//       default:
//         return 'Hesabınız yönetici onayı bekliyor.';
//     }
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
//               ? [const Color(0xFFE74C3C), const Color(0xFFC0392B)]
//               : [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
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
//   // ===== باقي الكود مثل ما هو (form + info card + build) =====
//
//   Widget _buildProfileForm() {
//     if (!_isEditing) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildInfoCard(
//             title: 'Şirket Bilgileri',
//             items: [
//               _buildInfoItem(icon: Icons.business, label: 'Şirket Adı', value: _profile?.companyName),
//               _buildInfoItem(icon: Icons.person, label: 'Yetkili Kişi', value: _profile?.contactPerson),
//               _buildInfoItem(icon: Icons.email, label: 'E-posta', value: _profile?.email),
//               _buildInfoItem(icon: Icons.phone, label: 'Telefon', value: _profile?.companyPhone),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildInfoCard(
//             title: 'Detaylar',
//             items: [
//               _buildInfoItem(icon: Icons.work, label: 'Sektör', value: _profile?.sector),
//               _buildInfoItem(icon: Icons.location_on, label: 'Adres', value: _profile?.address),
//               _buildInfoItem(icon: Icons.language, label: 'Website', value: _profile?.website),
//               _buildInfoItem(icon: Icons.numbers, label: 'Vergi No', value: _profile?.taxNo),
//             ],
//           ),
//           const SizedBox(height: 20),
//           if (_profile?.companyDescription?.isNotEmpty == true)
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Şirket Açıklaması',
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
//                     _profile!.companyDescription!,
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
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           const Text(
//             '🏢 Şirket Bilgileri',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           CustomTextField(
//             controller: _companyNameController,
//             label: 'Şirket Adı',
//             prefixIcon: Icons.business,
//             isRequired: true,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _contactPersonController,
//             label: 'Yetkili Kişi',
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
//             isRequired: true,
//           ),
//           const SizedBox(height: 30),
//
//           const Text(
//             '📊 Sektör ve Detaylar',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Sektör',
//                 style: TextStyle(
//                   color: Color(0xFF2C3E50),
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFE0E0E0)),
//                 ),
//                 child: DropdownButton<String>(
//                   value: _selectedSector,
//                   isExpanded: true,
//                   underline: const SizedBox(),
//                   hint: const Text('Sektör seçin'),
//                   icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
//                   items: _sectors.map((String sector) {
//                     return DropdownMenuItem<String>(
//                       value: sector,
//                       child: Text(sector),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedSector = newValue;
//                     });
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Şirket Büyüklüğü',
//                 style: TextStyle(
//                   color: Color(0xFF2C3E50),
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: const Color(0xFFE0E0E0)),
//                 ),
//                 child: DropdownButton<String>(
//                   value: _selectedCompanySize,
//                   isExpanded: true,
//                   underline: const SizedBox(),
//                   hint: const Text('Şirket büyüklüğü seçin'),
//                   icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF2C3E50)),
//                   items: _companySizes.map((String size) {
//                     return DropdownMenuItem<String>(
//                       value: size,
//                       child: Text(size),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedCompanySize = newValue;
//                     });
//                   },
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _addressController,
//             label: 'Adres',
//             prefixIcon: Icons.location_on,
//             maxLines: 2,
//             isRequired: true,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _websiteController,
//             label: 'Website',
//             prefixIcon: Icons.language,
//             keyboardType: TextInputType.url,
//           ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             controller: _taxNoController,
//             label: 'Vergi No',
//             prefixIcon: Icons.numbers,
//             keyboardType: TextInputType.number,
//           ),
//           const SizedBox(height: 30),
//
//           const Text(
//             '📖 Şirket Açıklaması',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           CustomTextField(
//             controller: _descriptionController,
//             label: 'Şirketinizi tanıtın',
//             prefixIcon: Icons.description,
//             maxLines: 5,
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
//           Icon(icon, color: const Color(0xFFE74C3C), size: 20),
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
//         title: const Text('Şirket Profili'),
//         backgroundColor: const Color(0xFFE74C3C),
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
//         child: CircularProgressIndicator(color: Color(0xFFE74C3C)),
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
//     _companyNameController.dispose();
//     _contactPersonController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _sectorController.dispose();
//     _addressController.dispose();
//     _websiteController.dispose();
//     _taxNoController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }
