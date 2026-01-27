import 'package:btab/home/bloc/home_bloc.dart';
import 'package:btab/home/widgets/bookCard.dart';
import 'package:btab/home/widgets/searchBook.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocBuilder<HomeBloc,HomeState>(builder: (context, state) {
          print(state.toString());
          if(state is HomeLoading){
            return const Center(child: CircularProgressIndicator());
          }
          if(state is HomeError){
            return Center(child: Text(state.message));
          }
       if(state is HomeLoaded){
         print(state.books.title);
         return Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Searchbook(onSearch: (String s){
      
             }),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Bookcard(b: state.books),
          )
           ],
         );
        }
       return Center(child: Text("something went wrong"));
        },
       )
      ),
    );
  }
}
