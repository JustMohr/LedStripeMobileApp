import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SettingsHome(),
    );
  }
}*/



class SettingsHome extends StatelessWidget {

  SettingsHome(this.ipTxt);
  final String ipTxt;
  final textController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    textController.text = ipTxt;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        //resizeToAvoidBottomInset: false,
        appBar: AppBar(),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                if(MediaQuery.of(context).viewInsets.bottom < 100)
                Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.width * 0.35),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'IP - settings',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    )
                  ]
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: TextField(
                            controller: textController,
                            textAlign: TextAlign.center,
                            //decoration: InputDecoration(hintText: 'ip'),
                          )
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        child: Icon(Icons.check),
                        onPressed: (){
                          safeIp();
                          Navigator.pop(context, textController.text);
                        },
                      ),
                    ],
                  ),
                )
              ],
            )
          ),
        ),
      ),
    );
  }

  void safeIp() async {

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('ip_LEDSystem', textController.text);

  }
}

