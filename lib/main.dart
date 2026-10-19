import 'package:flutter/material.dart';

import 'router/router_apk.dart';
import 'themes/theme_apk.dart';

void main() => runApp(const Myapp());

class Myapp extends StatelessWidget {
  const Myapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RouterApk.rutaInicial,
      routes: RouterApk.rutasApk,
      onGenerateRoute: RouterApk.generarRuta,
      theme: ThemeApk.modoApk,
    );
  }
}
