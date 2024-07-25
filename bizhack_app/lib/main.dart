import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:barcode/barcode.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

Future<void> submitSurveyToServer(String hobbies, String groceries) async {
  final url = 'http://localhost:3000';
  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'hobbies': hobbies,
      'groceries': groceries,
    }),
  );

  if (response.statusCode == 200) {
    print('Survey submitted successfully!');
  } else {
    print('Failed to submit survey.');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INFOSYS BizHack',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SurveyPage(), // Directly set the home page to HomePage
    );
  }
}

class SurveyPage extends StatefulWidget {
  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final _hobbies = [
    'Reading',
    'Traveling',
    'Cooking',
    'Gaming',
    'Music'
  ];

  final _groceries = [
    'Apple',
    'Fish',
    'Yogurt',
    'Bread',
    'Orange',
    'Carrot',
    'Beef',
    'Butter',
    'Potato',
    'Soda',
    'Spinach',
    'Broccoli',
    'Chicken',
    'Cookies',
    'Banana',
    'Juice',
    'Chips',
    'Shrimp',
    'Tomato',
  ];

  final List<String> _selectedHobbies = [];
  final List<String> _dislikedGroceries = [];
  String? _selectedProfession;

  final List<String> _professions = [
    'Software Engineer',
    'Doctor',
    'Teacher',
    'Artist',
    'Chef'
  ];

  void _submitSurvey() async {
    final selectedHobbies = _selectedHobbies.join(', ');
    final dislikedGroceries = _dislikedGroceries.join(', ');

    if (_selectedProfession == null || selectedHobbies.isEmpty || dislikedGroceries.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill all fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    try {
      // Prepare CSV data
      List<List<dynamic>> rows = [
        ["Selected Hobbies", "Disliked Groceries"],
        [selectedHobbies, dislikedGroceries],
      ];

      // Convert to CSV
      submitSurveyToServer(selectedHobbies, dislikedGroceries);

      Fluttertoast.showToast(
        msg: 'Survey submitted and saved successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error during survey submission: $e');
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void _skipSurvey() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        backgroundColor: Colors.black12,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select your hobbies:', style: TextStyle(fontSize: 18.0, color: Color(0xFF007CC3))),
            ..._hobbies.map((hobby) => Container(
              margin: EdgeInsets.symmetric(vertical: 4.0),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text(
                  hobby,
                  style: TextStyle(fontSize: 14.0),
                ),
                value: _selectedHobbies.contains(hobby),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedHobbies.add(hobby);
                    } else {
                      _selectedHobbies.remove(hobby);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                activeColor: Color(0xFF007CC3),
              ),
            )),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedProfession,
              hint: Text('Select your profession', style: TextStyle(color: Color(0xFF007CC3))),
              items: _professions.map((profession) {
                return DropdownMenuItem<String>(
                  value: profession,
                  child: Text(profession),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProfession = newValue;
                });
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF007CC3)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF007CC3)),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Select groceries you don\'t like:', style: TextStyle(fontSize: 18.0, color: Color(0xFF007CC3))),
            ..._groceries.map((grocery) => Container(
              margin: EdgeInsets.symmetric(vertical: 4.0),
              child: CheckboxListTile(
                contentPadding: EdgeInsets.all(0),
                title: Text(
                  grocery,
                  style: TextStyle(fontSize: 14.0),
                ),
                value: _dislikedGroceries.contains(grocery),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _dislikedGroceries.add(grocery);
                    } else {
                      _dislikedGroceries.remove(grocery);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                activeColor: Color(0xFF007CC3),
              ),
            )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSurvey,
              child: Text('Submit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFF007CC3),
                textStyle: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _skipSurvey,
              child: Text('Skip Survey'),
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF007CC3),
                textStyle: TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when the page initializes
  }
  Future<void> _fetchProducts() async {
    try {
      final url = 'http://localhost:3000/data';  // Replace with your endpoint
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final Product product = Product.fromJson(jsonResponse);
        setState(() {
          products = [product]; // Wrap the single product in a list
        });
      } else {
        print('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  List<Product> cartItems = [];
  String selectedCategory = 'all';

  void addToCart(Product product) {
    setState(() {
      final existingProductIndex = cartItems.indexWhere((item) => item.id == product.id);
      if (existingProductIndex >= 0) {
        cartItems[existingProductIndex].increaseQuantity();
      } else {
        cartItems.add(product);
      }
    });

    Fluttertoast.showToast(
      msg: '${product.name} added to cart',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void removeFromCart(int index) {
    setState(() {
      final productId = cartItems[index].id;
      cartItems[index].decreaseQuantity();
      if (cartItems[index].quantity == 0) {
        cartItems.removeAt(index);
      }
    });
  }


  void filterProducts(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  List<Product> getFilteredProducts() {
    if (selectedCategory == 'all') {
      return products;
    } else {
      return products.where((product) => product.name.contains(selectedCategory)).toList();
    }
  }

  double getTotalCartValue() {
    double total = 0.0;
    cartItems.forEach((item) {
      total += item.price;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'INFOSYS BizHack',
              style: TextStyle(color: Color(0xFF007CC3)),
            ),
            SizedBox(width: 10),
            Spacer(),
            IconButton(
              icon: Icon(Icons.contact_phone, color: Color(0xFF007CC3)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Contact'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('INFOSYS'),
                          SizedBox(height: 10),
                          Text('Telephone: 123-456-789'),
                          SizedBox(height: 10),
                          Text('Email: infosys@bizhack.pl'),
                          SizedBox(height: 10),
                          Text('Headquaters: Bangalore'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.menu, color: Color(0xFF007CC3)),
              onSelected: (String result) {
                filterProducts(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'all',
                  child: Text('ALL'),
                ),
                const PopupMenuItem<String>(
                  value: 'Dom i Ogród',
                  child: Text('Dom i Ogród'),
                ),
                const PopupMenuItem<String>(
                  value: 'Dziecko',
                  child: Text('Dziecko'),
                ),
                const PopupMenuItem<String>(
                  value: 'Zdrowie',
                  child: Text('Zdrowie'),
                ),
              ],
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart, color: Color(0xFF007CC3)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(
                          cartItems: cartItems,
                          onRemove: (index) {
                            removeFromCart(index);
                          },
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 0,
                  child: cartItems.isEmpty
                      ? Container()
                      : CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${cartItems.length}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.assignment, color: Color(0xFF007CC3)), // The new icon
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurveyPage(), // Navigate to SurveyPage
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.black12,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 20.0,
                mainAxisSpacing: 20.0,
                childAspectRatio: 0.7,
              ),
              itemCount: getFilteredProducts().length,
              itemBuilder: (context, index) {
                final product = getFilteredProducts()[index];
                return ProductBox(
                  product: product,
                  onOrder: () {
                    addToCart(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductBox extends StatelessWidget {
  final Product product;
  final VoidCallback onOrder;

  ProductBox({required this.product, required this.onOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1.0,
        ),
      ),
      child: Card(
        elevation: 2.0,
        margin: EdgeInsets.all(5.0),
        color: Colors.white70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(product: product),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0), // Optional: Add border radius for a rounded look
                  child: AspectRatio(
                    aspectRatio: 1.0, // Adjust aspect ratio as needed
                    child: Image.network(
                      product.id,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    '${product.price} zł',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: onOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                    ),
                    child: Text(
                      'Order',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<Product> cartItems;
  final Function(int) onRemove;

  CartPage({required this.cartItems, required this.onRemove});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Map<String, Product> cartItemsMap;

  @override
  void initState() {
    super.initState();
    cartItemsMap = _groupProductsById(widget.cartItems);
  }

  @override
  void didUpdateWidget(covariant CartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartItems != widget.cartItems) {
      setState(() {
        cartItemsMap = _groupProductsById(widget.cartItems);
      });
    }
  }

  Map<String, Product> _groupProductsById(List<Product> items) {
    final Map<String, Product> groupedItems = {};
    for (var item in items) {
      if (groupedItems.containsKey(item.id)) {
        groupedItems[item.id]?.increaseQuantity();
      } else {
        groupedItems[item.id] = item;
      }
    }
    return groupedItems;
  }

  double getTotalCartValue() {
    double total = 0.0;
    cartItemsMap.values.forEach((item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.black12,
      ),
      body: cartItemsMap.isEmpty
          ? Center(child: Text('Your cart is empty'))
          : ListView.builder(
        itemCount: cartItemsMap.length,
        itemBuilder: (context, index) {
          final product = cartItemsMap.values.elementAt(index);
          return Card(
            margin: EdgeInsets.all(10.0),
            child: ListTile(
              contentPadding: EdgeInsets.all(10.0),
              title: Text(product.name),
              subtitle: Text('${product.price} zł x ${product.quantity}'),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    if (product.quantity > 1) {
                      product.decreaseQuantity();
                    } else {
                      widget.onRemove(cartItemsMap.keys.toList().indexOf(product.id));
                      cartItemsMap.remove(product.id);
                    }
                  });
                },
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.black12,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: ${getTotalCartValue().toStringAsFixed(2)} zł',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarcodePage(data: getTotalCartValue().toStringAsFixed(2)),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                'Proceed to Pay',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class ProductDetailsPage extends StatelessWidget {
  final Product product;

  ProductDetailsPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        backgroundColor: Colors.black12,
      ),
      body: Column(
        children: [
          Text(
            product.name,
            style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          Text(
            '${product.price} zł',
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text(
              'Back to Shop',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}

class BarcodePage extends StatelessWidget {
  final String data;

  BarcodePage({required this.data});

  @override
  Widget build(BuildContext context) {
    final barcode = Barcode.code128();
    final svg = barcode.toSvg(data, width: 200, height: 80);

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.black12,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total Price: $data zł'),
            SizedBox(height: 20.0),
            Container(
              color: Colors.white,
              child: SvgPicture.string(
                svg,
                width: 200,
                height: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String id;
  final String name;
  final double price;
  int quantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  static const Map<int, String> productNameMap = {
    0: 'Apple',
    1: 'Fish',
    2: 'Yogurt',
    3: 'Milk',
    4: 'Bread',
    5: 'Orange',
    6: 'Carrot',
    7: 'Beef',
    8: 'Butter',
    9: 'Potato',
    10: 'Soda',
    11: 'Spinach',
    12: 'Broccoli',
    13: 'Chicken',
    14: 'Cookies',
    15: 'Banana',
    16: 'Juice',
    17: 'Chips',
    18: 'Shrimp',
    19: 'Tomato',
  };

  static const Map<int, double> productPriceMap = {
    0: 1.0,
    1: 5.0,
    2: 2.0,
    3: 1.5,
    4: 1.0,
    5: 0.8,
    6: 0.7,
    7: 7.0,
    8: 3.0,
    9: 0.5,
    10: 1.0,
    11: 1.2,
    12: 1.5,
    13: 6.0,
    14: 2.5,
    15: 0.6,
    16: 2.0,
    17: 1.5,
    18: 8.0,
    19: 1.0,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    final int id = json['product_type'];
    final String name = productNameMap[id] ?? 'Unknown';
    final double basePrice = productPriceMap[id] ?? 0.0;
    final double discount = json['forecasted_discount'].toDouble() / 100;
    final double price = _truncateToTwoDecimalPlaces(basePrice * (1 - discount));

    return Product(
      id: id.toString(),
      name: name,
      price: price,
      quantity: 1
    );
  }

  static double _truncateToTwoDecimalPlaces(double value) {
    return (value * 100).truncateToDouble() / 100;
  }

  void increaseQuantity() {
    quantity++;
  }

  void decreaseQuantity() {
    if (quantity > 1) {
      quantity--;
    }
  }
}
