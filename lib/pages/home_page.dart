import 'package:agrifarm/consts.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'add_product.dart';
import 'weather.dart';
import 'my_orders.dart';
import 'profile_page.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final dio = Dio();

  List<Product> products = List.empty();

  void request() async {
    Response response;
    response = await dio.get('http://${server_url}/api/product');
    String serverResponse = response.data.toString();

    // Parse the JSON array
    List<dynamic> productsJson = json.decode(serverResponse);

    // Convert each product JSON to a Product object
    setState(() {
      products = productsJson.map((json) => Product.fromJson(json)).toList();
    });
    // Now 'products' is a List<Product> that you can use in your app frontend
    print("products");
    print(products);
  }

  User? _user;

  @override
  void initState() {
    super.initState();
    request();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              height: 500, // Adjust the height as needed
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/Hero.jpg'), // Replace with your image asset
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            top: 60.0), // Add padding to the top
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'AGRI',
                              style: TextStyle(
                                color: Colors.grey[900],
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'FARM',
                              style: TextStyle(
                                color: Color.fromARGB(255, 24, 156, 19),
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Text(
                          'Empowering farmers with Modern Ecommerce Solution. \nExplore, Transact and Thrive in Agriculture. \nDiscover Quality tools, Accurate Prediction and Growing Community.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for a product',
                      prefixIcon: Icon(Icons.search),
                    ),
                    // Implement search functionality
                  ),
                  SizedBox(height: 20),
                  // Product Feed using ListView.builder
                  Container(
                    height: 800,
                    color: Colors.grey[200],
                    child: ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        Product product = products[index];

                        // Check your conditions here
                        if (product.status == "verified") {
                          // Specify the maximum length of the description you want to display

                          // Return ProductCard with modified description
                          return ProductCard(
                            product: Product(
                              // Pass other properties of the product
                              id: product.id,
                              name: product.name,
                              description: product.description,
                              image: product.image,
                              images: product.images,
                              brand: product.brand,
                              price: product.price,
                              status: product.status,
                              creator: product.creator,
                              rating: product.rating,
                              isFeatured: product.isFeatured,
                              location: product.location,
                              contact: product.contact,
                              dateCreated: product.dateCreated,
                              // Add other properties as needed
                            ),
                          );
                        }
                        // Return an empty container if the conditions are not met
                        return Container();
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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
  final int price;
  final String status;
  final String creator;
  final double rating;
  final bool isFeatured;
  final String location;
  final String contact;
  final String dateCreated;

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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      // Use null-aware operator for List<String> conversion
      images: List<String>.from(json['images'] ?? []),
      brand: json['brand'] ?? '',
      price: json['price'] ??
          0.0, // Assuming price is a double, use appropriate default value
      status: json['status'] ?? '',
      creator: json['creator'] ?? '',
      // Handle the case where 'rating' might be null or not a double
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      isFeatured: json['isFeatured'] ?? false,
      location: json['location'] ?? '',
      contact: json['contact'] ?? '',
      dateCreated: json['dateCreated'] ?? '',
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int maxDescriptionLength = 100; // Change this value as needed

// Get the truncated description
    String displayDescription =
        product.description.length > maxDescriptionLength
            ? '${product.description.substring(0, maxDescriptionLength)}...'
            : product.description;

    return Card(
      elevation: 5.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.image,
              width: 370,
              fit: BoxFit.cover,
            ),
            Text(
              product.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              displayDescription,
            ),
            SizedBox(height: 8.0),
            Text('\$${product.price.toString()}'),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Show a modal when the "View Details" button is pressed
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Display all product details in the modal
                            Image.network(
                              product.image,
                              width: 370,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(product.description),
                            Text('\$${product.price.toString()}'),
                            // Add other product details as needed

                            // Button to redirect to the payment page
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PaymentPage(product: product),
                                  ),
                                );
                              },
                              child: Text("Proceed to Payment"),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text("View Details"),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsModal extends StatelessWidget {
  final Product product;

  const ProductDetailsModal({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(product.description),
          SizedBox(height: 8.0),
          Text('\$${product.price.toString()}'),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              // Navigate to the payment page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentPage(product: product),
                ),
              );
            },
            child: Text("Proceed to Payment"),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  final Product product;

  const PaymentPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your payment page UI here
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Payment Page for ${product.name}",
              style: TextStyle(fontSize: 20),
            ),
            // Add payment-related UI components
          ],
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(0.0),
            child: Image.asset(
              'assets/images/logo.png', // Replace with the actual path to your image
              width: 50.0, // Adjust the width as needed
            ),
          ),
          Text(
            'AGRI',
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            'FARM',
            style: TextStyle(
              color: Color.fromARGB(255, 24, 156, 19),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ), // Replace with your app's logo icon
          // Replace with your app's name
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.menu), // Replace with your toggle icon
          onPressed: () {
            // Open your toggle switch or drawer here
            _showNavigationMenu(context);
          },
        ),
      ],
    );
  }
}

Widget _buildNavigationMenuItem(
    BuildContext context, String title, VoidCallback onPressed) {
  return ListTile(
    title: Text(title),
    onTap: onPressed,
  );
}

void _showNavigationMenu(BuildContext context) {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNavigationMenuItem(context, 'Profile', () {
            Navigator.pop(context);
            // Navigate to the Profile page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          }),
          _buildNavigationMenuItem(context, 'Add product', () {
            Navigator.pop(context);
            // Navigate to the Add product page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddProductPage()),
            );
          }),
          _buildNavigationMenuItem(context, 'My orders', () {
            Navigator.pop(context);
            // Navigate to the My orders page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyOrdersPage()),
            );
          }),
          _buildNavigationMenuItem(context, 'Weather forecast', () {
            Navigator.pop(context);
            // Navigate to the Weather forecast page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WeatherForecastPage()),
            );
          }),
          MaterialButton(
            color: Colors.red,
            child: const Text("Sign Out"),
            onPressed: _auth.signOut,
          ),
        ],
      );
    },
  );
}
