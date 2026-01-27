import 'package:btab/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'home/ui/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // FIX 1: Add 'ColorScheme' before '.fromSeed'
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // FIX 2: Trigger the initial event so the Bloc starts fetching data
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc()..add(HomeGetBooksEvent()),
          ),
        ],
        child: const HomePage(),
      ),
    );
  }
}

// Note: MyHomePage is currently unused because 'home' points to HomePage