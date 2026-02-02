import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home/bloc/home_bloc.dart';
import 'home/data/home_repo.dart';
import 'home/data/home_services.dart';
import 'home/ui/home.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'B-Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(create: (context) => HomeRepo(HomeServices())),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => HomeBloc(
                homeRepo: context.read<HomeRepo>(),
              )..add(HomeGetBooksEvent()),
            ),
          ],
          child: const HomePage(),
        ),
      ),
    );
  }
}
