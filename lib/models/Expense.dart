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
        title: json['title'],
        description: json['description'],
        amount: json['amount'],
        imageUrl: json['imageUrl'],
        expenseId: json['id']
    );
  }
}