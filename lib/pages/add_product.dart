// second_page.dart
import 'package:agrifarm/consts.dart';
import 'package:agrifarm/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrifarm/main.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  File? _image;

  final Dio dio = Dio();
  String imageUrl = "";
  bool submitting = false;

  Future<void> _getImage() async {
    final imagePicker = ImagePicker();
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_image == null) {
      return;
    }

    final cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dcsvvfai3';
    final cloudinaryPreset = 'vtxkm6s0';

    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          _image!.path,
          filename: 'product_image',
        ),
        'upload_preset': cloudinaryPreset,
      });

      final response = await dio.post(
        '$cloudinaryUrl/image/upload',
        data: formData,
      );

      // Parse the Cloudinary response to get the image URL
      imageUrl = response.data['secure_url'];

      // Now, you can use 'imageUrl' to store in your product data or make API requests.
      print('Cloudinary Image URL: $imageUrl');
    } catch (e) {
      print('Error uploading image to Cloudinary: $e');
    }
  }

  Future<void> _submitForm() async {
    // Perform image upload to Cloudinary
    setState(() {
      submitting = true;
    });
    await _uploadImageToCloudinary();

    // Now, you can make a POST request to your API with product data

    final productData = {
      'userId': "fb_${_user!.uid}",
      'name': nameController.text,
      'description': descriptionController.text,
      'price': double.parse(priceController.text),
      'image_url': imageUrl, // Replace with the actual Cloudinary URL
      // Add other fields as needed
      'location': locationController.text,
    };

    try {
      final response = await dio.post(
        'http://${server_url}/api/product/new',
        data: jsonEncode(productData),
      );

      // Handle the API response as needed
      print('API Response: ${response.data}');
    } catch (e) {
      print('Error making POST request: $e');
    } finally {
      setState(() {
        submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Product Description'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Product Location'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('Select Image'),
              ),
              SizedBox(height: 16.0),
              _image != null ? Image.file(_image!) : Text('No image selected'),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(submitting ? "Submitting.." : "Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
