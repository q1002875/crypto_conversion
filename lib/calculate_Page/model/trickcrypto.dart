class SymbolCase {
  Trickcrypto symbolData;
  dynamic price;
  dynamic changePrice;
  dynamic changePercent;
  SymbolCase(this.symbolData, this.price, this.changePercent, this.changePrice);
}

class Trickcrypto {
  String id;
  String coin;
  String name;
  String image;
  bool iscrypto;
  bool isAdd;

  Trickcrypto(this.coin, this.id, this.name, this.image,
      {this.iscrypto = true, this.isAdd = false});

  // 從 JSON 轉換為 Trickcrypto 物件
  factory Trickcrypto.fromJson(Map<String, dynamic> json) {
    return Trickcrypto(
      json['coin'],
      json['id'],
      json['name'],
      json['image'],
      iscrypto: json['iscrypto'],
      isAdd: json['isAdd'],
    );
  }

  // 將 Trickcrypto 物件轉換為 JSON 格式
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coin': coin,
      'name': name,
      'image': image,
      'iscrypto': iscrypto,
      'isAdd': isAdd,
    };
  }
}
