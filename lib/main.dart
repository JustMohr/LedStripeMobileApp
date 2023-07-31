import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:led_stripe/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>{

  bool startPage = true;
  Icon btnIcon = Icon(Icons.switch_right);
  static late String ip;

  late Future<String> getIpFunc;


  Future<String> getIp() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String sharedIp = prefs.getString('ip_LEDSystem').toString();

    if(sharedIp == 'null'){

      final data = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SettingsHome('')
        ),
      );
      ip = data;
      return data;

    }

    return sharedIp;
  }

  @override
  void initState() {
    getIpFunc = getIp();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Liana'),
      ),
      body: Container(
        child: FutureBuilder<String?>(
          future: getIpFunc,
          builder: (context, snapshot) {

            if(!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            ip = snapshot.data.toString();
            return WView(ip);

          }
        )
      ),
        floatingActionButton: FloatingActionButton(
          child: btnIcon = (btnIcon.icon == Icon(Icons.switch_right).icon) ? Icon(Icons.switch_left) : Icon(Icons.switch_right),
          onPressed: () => setState(() {
            if(startPage){
              WViewState.controller.loadUrl('http://$ip/rails');
              WViewState.loadTimeOutFunc();

              startPage = false;
            }
            else{
              WViewState.controller.loadUrl('http://$ip/');
              WViewState.loadTimeOutFunc();

              startPage = true;
            }
          }),
        )
    );
  }
}




class WView extends StatefulWidget {

  String ip;
  WView(this.ip);

  @override
  State<WView> createState() => WViewState();
}

class WViewState extends State<WView> {

  bool errorPageShow = false;
  bool isPageLoaded = false;
  static late WebViewController controller;

  static late Function loadTimeOutFunc;

  @override
  void initState() {
    loadTimeOutFunc = loadTimeOut;
  }

  @override
  Widget build(BuildContext context) {

      return Stack(
        children: [
          webView(),
          Visibility(
              visible: errorPageShow,
              child: Center(child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                        child: ElevatedButton(
                          child: Icon(Icons.refresh, size: 40,),
                          style: ElevatedButton.styleFrom(
                              onPrimary: Colors.black,
                              primary: Colors.blue
                          ),
                          onPressed: () {
                            setState(() {
                              WViewState.controller.loadUrl('http://${widget.ip}/');
                              loadTimeOut();
                            });
                          },
                        ),
                      )
                  ),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.width * 0.2,
                        child: ElevatedButton(
                          child: const Icon(
                            Icons.settings_outlined, size: 40,),
                          style: ElevatedButton.styleFrom(
                              onPrimary: Colors.black,
                              primary: Colors.blue
                          ),

                          onPressed: () async{
                            final data = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SettingsHome(widget.ip)),
                            );

                            if(data != null){
                              widget.ip = data;
                              MyHomePageState.ip = data;
                            }

                            setState(() {
                              WViewState.controller.loadUrl('http://${widget.ip}/');
                              loadTimeOut();
                            });

                          },
                        ),
                      )
                  )
                ],
              ),)
          ),
          Visibility(
            visible: !errorPageShow && !isPageLoaded,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      );
  }


  WebView webView(){
    return WebView(
      initialUrl: 'http://${widget.ip}',
      javascriptMode: JavascriptMode.unrestricted,
      zoomEnabled: true,
      onWebViewCreated: (controller){
        WViewState.controller = controller;

        loadTimeOut();

      },
      onPageFinished: (url){
        setState(() {
          isPageLoaded = true;

          controller.evaluateJavascript("document.getElementsByTagName('h1')[0].remove();"); //remove h1

          controller.evaluateJavascript("document.getElementById('btnOnOff').style.width='160px'; "
              "document.getElementById('btnOnOff').style.height='80px';"
              "document.getElementById('btnOnOff').style.fontSize = '30px';"); //btn size

          if(url=='http://${widget.ip}/rails'){
            controller.evaluateJavascript(
                "document.getElementById('btnOnOff').style.marginTop = (window.innerHeight/2 - window.innerHeight/3).toString() +'px';"//slider margin
            );
          }else{
            controller.evaluateJavascript(
                "document.getElementById('btnOnOff').style.marginTop = (window.innerHeight/2 - window.innerHeight/3).toString() +'px';"//colorpicker margin
            );
          }
        });
      },
      onWebResourceError: (error){
        setState(() {
          errorPageShow = true;
          loadErrorPage();
        });
      },

    );
  }



  void loadTimeOut() async {
    errorPageShow = false;
    isPageLoaded = false;

    Timer(const Duration(seconds: 5), () {
      if (isPageLoaded == false) {
        setState(() {
          errorPageShow = true;
          loadErrorPage();
        });
      }
    });
  }



  String htmlData ="<!DOCTYPE html><html><head> <style> *{ font-family: Arial, Helvetica, sans-serif; } body{ background-color: orange; } h1{ margin-top: 50px; font-weight: bold; font-size: 40px; text-align: center; } p{ margin-top: 50px; text-align: center; font-size: 18px; margin-left: 10px; margin-right: 10px; } </style></head><body> <h1>Error</h1> <p>Check your WLAN-connection, the IP of the LED stripe and the status LED!</p></body></html>";

  void loadErrorPage(){
    final url = Uri.dataFromString(
        htmlData,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString();

    controller.loadUrl(url);

  }
}


