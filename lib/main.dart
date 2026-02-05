import 'package:btab/ai/data/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'ai/bloc/ai_bloc.dart';
import 'ai/data/ai_repo.dart';
import 'download_engine/bloc/download_bloc.dart';
import 'download_engine/data/download_repo.dart';
import 'download_engine/data/download_service.dart';
import 'home/bloc/home_bloc.dart';
import 'home/data/home_repo.dart';
import 'home/data/home_services.dart';
import 'home/ui/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  final client = http.Client();
  final homeService = HomeServices();
  final aiService = SummarizeService(client: client);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => HomeRepo(homeService),
        ),

        RepositoryProvider(
          create: (_) => DownloadRepo(DownloadService()),
        ),

        // ✅ AI Summarize Repository
        RepositoryProvider(
          create: (_) => SummarizeRepository(service: aiService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeBloc(
              homeRepo: context.read<HomeRepo>(),
              downloadService: DownloadService(),
            )..add(HomeGetBooksEvent()),
          ),

          BlocProvider(
            create: (context) => DownloadBloc(
              downloadRepo: context.read<DownloadRepo>(),
            ),
          ),

          // ✅ AI Summarize Bloc
          BlocProvider(
            create: (context) => SummarizeBloc(
              repository: context.read<SummarizeRepository>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );

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
      home: HomePage()
    );
  }
}
