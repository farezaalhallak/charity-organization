import 'package:flutter/material.dart';
import 'package:untitled/widgets/mediaTeam/main3.dart';
import 'package:untitled/widgets/receptionist/main4.dart';
import 'package:untitled/widgets/store/main2.dart';
import 'package:untitled/widgets/super_admin/main5.dart';
import 'package:untitled/widgets/visittime/mainvisit.dart';

class MyApp3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/main3': (context) => Main3(),
        '/main2': (context) => Main2(),
        '/main4': (context) => Main4(),
        '/main5': (context) => Main5(),
        '/mainvisit': (context) => Mainvisit(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/main3');
              },
              child: Text('Media Teams'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/main2');
              },
              child: Text('Store'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/main4');
              },
              child: Text('Reception'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/main5');
              },
              child: Text('Super Admin'),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mainvisit');
              },
              child: Text('Visit Team'),
            ),
          ],
        ),
      ),
    );
  }
}
