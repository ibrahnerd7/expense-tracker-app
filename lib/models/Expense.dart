class Expense {
  String title;
  String description;
  String amount;
  String imageUrl;
  String expenseId;

  Expense(
      {this.title, this.description, this.amount, this.imageUrl, this.expenseId});

  factory Expense.fromJson(Map<String, dynamic> json){
    return Expense(
        title: json['title'].toString(),
        description: json['description'].toString(),
        amount: json['amount'].toString(),
        imageUrl: json['imageUrl'].toString(),
        expenseId: json['id'].toString()
    );
  }
}