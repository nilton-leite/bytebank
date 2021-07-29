import 'dart:convert';

import 'package:bytebank/http/webclient.dart';
import 'package:bytebank/models/transaction.dart';
import 'package:http/http.dart';

class TransactionWebClient {
  // static const String baseUrl = 'http://192.168.1.67:8080/transactions';
  // static const String baseUrl = 'http://172.29.80.1:8080/transactions';

  Future<List<Transaction>> findAll() async {
    final Response response =
        await client.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 5));

    final List<dynamic> decodedJson = jsonDecode(response.body);
    return decodedJson
        .map((dynamic json) => Transaction.fromJson(json))
        .toList();
  }

  Future<Transaction?> save(Transaction transaction, String password) async {
    final String transactionJson = jsonEncode(transaction.toJson());

    final Response response = await client.post(Uri.parse(baseUrl),
        headers: {
          'Content-type': 'application/json',
          'password': password,
        },
        body: transactionJson);
    // .timeout(Duration(seconds: 15));

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    }

    throw HttpException(_getMessage(response.statusCode));
  }

  String? _getMessage(int statusCode) {
    if (_statusCodeResponses.containsKey(statusCode)) {
      return _statusCodeResponses[statusCode];
    }
    return 'Erro desconhecido...';
  }

  static final Map<int, String> _statusCodeResponses = {
    400: 'Ocorreu um erro ao enviar a transferencia!',
    401: 'Falha na autenticação!',
    409: 'A transação já existe',
  };
}

class HttpException implements Exception {
  final String? message;

  HttpException(this.message);
}
