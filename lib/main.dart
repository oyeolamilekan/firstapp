import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dasapp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'dasapp'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List product_data;
  var _isLoading = true;
  Widget appBarTitle;
  var actionIcon;
  final textController = TextEditingController();

  _create_icon() {
    appBarTitle = Text("Das Shop");
    actionIcon = new Icon(
      Icons.search,
      color: Colors.white,
    );
  }

  _getData() async {
    product_data = await fetchData();
    setState(() {
      _isLoading = false;
    });
  }

  _getSearchData(query) async {
    product_data = await searchData(query);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    print('hello world');
    _getData();
    _create_icon();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        centerTitle: true,
        elevation: 0.0,
        actions: <Widget>[
          new IconButton(
              icon: actionIcon,
              onPressed: () {
                setState(() {
                  if (this.actionIcon.icon == Icons.search) {
                    this.actionIcon = new Icon(
                      Icons.close,
                      color: Colors.white,
                    );
                    this.appBarTitle = new TextField(
                      style: new TextStyle(
                        color: Colors.black,
                      ),
                      onSubmitted: (str) {
                        // Directs them to search app
                        // Which does some magic
                        _getSearchData(str);
                        setState(() {
                          _isLoading = true;
                        });
                      },
                      controller: textController,
                      decoration: new InputDecoration(
                        prefixIcon: new Icon(Icons.search, color: Colors.white),
                        hintText: "Search...",
                        hintStyle: new TextStyle(color: Colors.white),
                        fillColor: Colors.white,
                      ),
                    );
                  } else {
                    this.actionIcon = new Icon(
                      Icons.search,
                      color: Colors.white,
                    );
                    this.appBarTitle = Text("Das App");
                  }
                });
              })
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : SafeArea(
                child: ListView.builder(
                itemBuilder: (context, i) {
                  final products = product_data[i];

                  return Column(
                    children: <Widget>[
                      Container(
                          padding: new EdgeInsets.all(12.0),
                          child: new FlatButton(
                            child: new Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Image.network(
                                  _getImageURL(products["image"]),
                                  width: 150.0,
                                ),
                                new Container(
                                  width: 12.0,
                                ),
                                new Flexible(
                                  child: new Container(
                                    margin: new EdgeInsets.all(13.0),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text(_getSubtitleText(
                                              products['name'])),
                                          new Container(
                                            height: 5.0,
                                          ),
                                          new Text('N' +
                                              products['price'].toString()),
                                          new Container(
                                            height: 5.0,
                                          ),
                                        ]),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              print(products['source_url']);
                            },
                          )),
                      new Divider(),
                    ],
                  );
                },
                itemCount: product_data != null ? product_data.length : 0,
              )),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _getSubtitleText(String productName) {
    String percentChangeTextWidget;

    productName.length > 100
        ? percentChangeTextWidget = productName.substring(0, 50) + '.....'
        : percentChangeTextWidget = productName;

    return percentChangeTextWidget;
  }

  _getImageURL(String url) {
    return url.contains('cloudinary')
        ? url
        : "https://res.cloudinary.com/dbwm0ksoi/image/upload/v1/${url}";
  }

  Future<List> fetchData() async {
    http.Response response = await http.get(
        'https://rifqoe.herokuapp.com/api/shop_product/yipada-stores/index/');
    List data = json.decode(response.body)['results'];
    return data;
  }

  Future<List> searchData(String query) async {
    http.Response response = await http.get(
        'https://rifqoe.herokuapp.com/api/r_search/yipada-stores/?q=${query}');
    List data = json.decode(response.body)['results'];
    print(data);
    print(json.decode(response.body));
    return data;
  }
}
