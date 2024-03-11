import 'dart:convert';

import 'package:agrifarm/consts.dart';
import 'package:agrifarm/pages/home_page.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrifarm/main.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
        if (_user != null) {
          fetchOrders();
        }
      });
    });
  }

  List<Order> orders = []; // Populate this list with orders from the server

  final Dio dio = Dio();

  void fetchOrders() async {
    try {
      final response = await dio.get(
        'http://${server_url}/api/users/fb_${_user?.uid}/orders',
      );

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON
        List<dynamic> jsonResponse = json.decode(response.data);
        List<Order> fetchedOrders =
            jsonResponse.map((data) => Order.fromJson(data)).toList();

        setState(() {
          orders = fetchedOrders;
        });
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to load orders');
      }
    } catch (error) {
      // Handle network errors or other exceptions
      print('Error fetching orders: $error');
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: _user == null
          ? MyApp()
          : Center(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return OrderCard(order: orders[index]);
                },
              ),
            ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final Order order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        title: Text(widget.order.product.name),
        subtitle: Text('Total Amount: \$${widget.order.rate.toString()}'),
        // Add other fields as needed
      ),
    );
  }
}

class Userdata {
  final String id;
  final String name;
  final String email;
  final String image;
  final String passwordHash;
  final String phone;
  final String isVerified;
  final String street;
  final String aadharCard;
  final String aadharNo;
  final String city;
  final String country;

  Userdata({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.passwordHash,
    required this.phone,
    required this.isVerified,
    required this.street,
    required this.aadharCard,
    required this.aadharNo,
    required this.city,
    required this.country,
  });

  factory Userdata.fromJson(Map<String, dynamic> json) {
    return Userdata(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
      passwordHash: json['passwordHash'],
      phone: json['phone'],
      isVerified: json['isVerified'],
      street: json['street'],
      aadharCard: json['aadharCard'],
      aadharNo: json['aadharNo'],
      city: json['city'],
      country: json['country'],
    );
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final List<String> images;
  final String brand;
  final double price;
  final String status;
  final String creator;
  final double rating;
  final bool isFeatured;
  final String location;
  final String contact;
  final DateTime dateCreated;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.images,
    required this.brand,
    required this.price,
    required this.status,
    required this.creator,
    required this.rating,
    required this.isFeatured,
    required this.location,
    required this.contact,
    required this.dateCreated,
  });
}

class Order {
  final String id;
  final Userdata owner;
  final Userdata customer;
  final Product product;
  final String status;
  final String shippingAddress;
  final String paymentMethod;
  final double rate;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.owner,
    required this.customer,
    required this.product,
    required this.status,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.rate,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      owner: json['owner'],
      customer: json['customer'],
      product: json['product'],
      status: json['status'],
      shippingAddress: json['shippingAddress'],
      paymentMethod: json['paymentMethod'],
      rate: json['rate'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
