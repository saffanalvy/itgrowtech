class SignalModel {
  int? id;
  int? actualTime;
  String? comment;
  String? pair;
  int? cmd;
  int? tradingSystem;
  String? period;
  double? price;
  double? sl;
  double? tp;

  SignalModel(
      {this.id,
      this.actualTime,
      this.comment,
      this.pair,
      this.cmd,
      this.tradingSystem,
      this.period,
      this.price,
      this.sl,
      this.tp});

  SignalModel.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    actualTime = json['ActualTime'];
    comment = json['Comment'];
    pair = json['Pair'];
    cmd = json['Cmd'];
    tradingSystem = json['TradingSystem'];
    period = json['Period'];
    price = json['Price'];
    sl = json['Sl'];
    tp = json['Tp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['ActualTime'] = this.actualTime;
    data['Comment'] = this.comment;
    data['Pair'] = this.pair;
    data['Cmd'] = this.cmd;
    data['TradingSystem'] = this.tradingSystem;
    data['Period'] = this.period;
    data['Price'] = this.price;
    data['Sl'] = this.sl;
    data['Tp'] = this.tp;
    return data;
  }
}