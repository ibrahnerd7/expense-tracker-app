import 'package:expense_app/models/Expense.dart';
import 'package:flutter/material.dart';

class ExpenseDetails extends StatefulWidget {
  @override
  _ExpenseDetailsState createState() => _ExpenseDetailsState();
}

class _ExpenseDetailsState extends State<ExpenseDetails> {
  @override
  Widget build(BuildContext context) {
    final Expense expense = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    title: Text(
                      expense.title,
                    ),
                    background: Hero(
                        tag: "${expense.description}${expense.expenseId}",
                        child: Image.network(
                          expense.imageUrl,
                          fit: BoxFit.cover,
                        ))),
              ),
            ];
          },
          body: Container(
            child: Text(expense.description),
          )),
    );
  }
}
