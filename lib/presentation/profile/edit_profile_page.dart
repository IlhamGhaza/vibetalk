import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vibetalk/presentation/auth/widget/auth_button.dart';

import '../../core/utils/permission.dart';
import '../../core/utils/snackbar_utils.dart';

import '../../data/models/user_model.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _profileImage;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  bool _isLoading = false;
  String? _initialPhotoUrl;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final docSnap = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (docSnap.exists && mounted) {
          final userData = UserModel.fromDocumentSnapshot(docSnap);
          _usernameController.text = userData.userName;
          _emailController.text = userData.email;
          setState(() {
            _initialPhotoUrl = userData.photo;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils(
          text: 'Gagal memuat data pengguna: $e',
          backgroundColor: Colors.red,
        ).showErrorSnackBar(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _uploadProfileImage(File imageFile, String userId) async {
    try {
      const int maxFileSize = 5 * 1024 * 1024;
      if (await imageFile.length() > maxFileSize) {
        if (mounted) {
          SnackbarUtils(
            text: 'Ukuran file maksimal adalah 5MB.',
            backgroundColor: Colors.red,
          ).showErrorSnackBar(context);
        }
        return null;
      }

      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef
          .child('images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await imageRef.putFile(imageFile);
      return await imageRef.getDownloadURL();
    } catch (e) {
      if (mounted) {
        SnackbarUtils(
          text: 'Gagal mengunggah gambar: $e',
          backgroundColor: Colors.red,
        ).showErrorSnackBar(context);
      }
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          SnackbarUtils(
            text: 'Pengguna tidak ditemukan. Silakan login kembali.',
            backgroundColor: Colors.red,
          ).showErrorSnackBar(context);
        }
        setState(() => _isLoading = false);
        return;
      }

      String? finalPhotoUrl = _initialPhotoUrl;

      if (_profileImage != null) {
        finalPhotoUrl = await _uploadProfileImage(_profileImage!, user.uid);
        if (finalPhotoUrl == null && mounted) {
          setState(() => _isLoading = false);
          return;
        }
      }

      Map<String, dynamic> userDataToUpdate = {
        'userName': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'photo': finalPhotoUrl,
      };

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userDataToUpdate, SetOptions(merge: true));

      if (mounted) {
        SnackbarUtils(
          text: 'Profil berhasil diperbarui!',
          backgroundColor: Colors.green,
        ).showSuccessSnackBar(context);
        await _fetchUserData();
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        log('Error saving profile: $e');
        SnackbarUtils(
          text: 'Gagal menyimpan profil: $e',
          backgroundColor: Colors.red,
        ).showErrorSnackBar(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getImageFromCamera() async {
    Navigator.pop(context);
    try {
      bool hasPermission = await checkCameraPermission();
      if (hasPermission && mounted) {
        final XFile? photo = await ImagePicker().pickImage(
          source: ImageSource.camera,
        );

        if (photo != null) {
          setState(() {
            _profileImage = File(photo.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils(
          text: 'Tidak dapat mengakses kamera: $e',
          backgroundColor: Colors.red,
        ).showErrorSnackBar(context);
      }
    }
  }

  Future<void> _getImageFromGallery() async {
    Navigator.pop(context);
    try {
      bool hasPermission = await checkAndroidExternalStoragePermission();
      if (hasPermission && mounted) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (image != null) {
          setState(() {
            _profileImage = File(image.path);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils(
          text: 'Tidak dapat mengakses galeri: $e',
          backgroundColor: Colors.red,
        ).showErrorSnackBar(context);
      }
    }
  }

  void _deleteProfileImage() {
    Navigator.pop(context);
    setState(() {
      _profileImage = null;
      _initialPhotoUrl = null;
    });
    if (mounted) {
      SnackbarUtils(
        text: 'Foto profil akan dihapus saat disimpan.',
        backgroundColor: Colors.orange,
      ).showSuccessSnackBar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
              tooltip: 'Simpan Profil',
            ),
        ],
      ),
      body: _isLoading && _usernameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                                    as ImageProvider<Object>?
                              : (_initialPhotoUrl != null &&
                                            _initialPhotoUrl!.isNotEmpty
                                        ? NetworkImage(_initialPhotoUrl!)
                                        : null)
                                    as ImageProvider?,
                          child:
                              (_profileImage == null &&
                                  (_initialPhotoUrl == null ||
                                      _initialPhotoUrl!.isEmpty))
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey[600],
                                )
                              : null,
                        ),
                        Material(
                          color: Theme.of(context).primaryColor,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _showBottomSheet(context),
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AuthButton(
                      text: 'Save',
                      onPressed: () {
                        _saveProfile();
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomSheetOption(
                    Icons.camera,
                    'Kamera',
                    onTap: _getImageFromCamera,
                  ),
                  _buildBottomSheetOption(
                    Icons.image,
                    'Galeri',
                    onTap: _getImageFromGallery,
                  ),
                  _buildBottomSheetOption(
                    Icons.delete,
                    'Hapus',
                    onTap: _deleteProfileImage,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetOption(
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Color(0xffE4E4E7),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}
