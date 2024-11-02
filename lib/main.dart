import 'package:flutter/material.dart';

void main() {
  runApp(const CurrencyConverterApp());
}

class CurrencyConverterApp extends StatelessWidget {
  const CurrencyConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const CurrencyConverterPage(),
    );
  }
}

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController =
      TextEditingController(text: "1000.00");
  String _fromCurrency = "MDL";
  String _toCurrency = "USD";
  double _convertedAmount = 736.70;
  double _exchangeRate = 17.65;

  final List<String> _currencies = ['MDL', 'USD', 'EUR'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Currency Converter',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 40),
            _buildCurrencyInputSection(),
            const SizedBox(height: 20),
            _buildConvertedAmountSection(),
            const SizedBox(height: 40),
            _buildExchangeRateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyInputSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCurrencyDropdownRow("Amount", _fromCurrency, _amountController),
          const SizedBox(height: 16),
          _buildSwapIcon(),
          const SizedBox(height: 16),
          _buildCurrencyDropdownRow("Converted Amount", _toCurrency, null),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdownRow(
      String label, String currency, TextEditingController? controller) {
    return Row(
      children: [
        _buildCurrencyDropdown(currency),
        const SizedBox(width: 16),
        Expanded(
          child: controller != null
              ? TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: const TextStyle(color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (value) {
                    _updateConversion(); // Actualizează conversia la apăsarea Enter
                  },
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _convertedAmount.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(String currency) {
    return DropdownButton<String>(
      value: currency,
      onChanged: (value) {
        setState(() {
          if (currency == _fromCurrency) {
            _fromCurrency = value!;
          } else {
            _toCurrency = value!;
          }
          _updateConversion();
        });
      },
      items: _currencies.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Text(value),
            ],
          ),
        );
      }).toList(),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildSwapIcon() {
    return InkWell(
      onTap: () {
        setState(() {
          String temp = _fromCurrency;
          _fromCurrency = _toCurrency;
          _toCurrency = temp;

          _updateConversion();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.indigoAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.indigoAccent.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.swap_horiz,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildConvertedAmountSection() {
    return const SizedBox.shrink();
  }

  Widget _buildExchangeRateSection() {
    return Text(
      '1 $_fromCurrency = ${_exchangeRate.toStringAsFixed(2)} $_toCurrency',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: Colors.indigo,
      ),
    );
  }

  void _updateConversion() {
    setState(() {
      double amount = double.tryParse(_amountController.text) ?? 0;

      if (amount < 0) {
        _showErrorDialog("The input value cannot be null or negative");
        return;
      }

      // Verifică dacă monedele sunt aceleași și setează rata de schimb la 1:1
      if (_fromCurrency == _toCurrency) {
        _exchangeRate = 1;
        _convertedAmount = amount;
      } else {
        if (_fromCurrency == 'USD' && _toCurrency == 'MDL') {
          _exchangeRate = 17.65;
          _convertedAmount = amount * _exchangeRate;
        } else if (_fromCurrency == 'MDL' && _toCurrency == 'USD') {
          _exchangeRate = 1 / 17.65;
          _convertedAmount = amount * _exchangeRate;
        } else if (_fromCurrency == 'EUR' && _toCurrency == 'USD') {
          _exchangeRate = 1.1;
          _convertedAmount = amount * _exchangeRate;
        } else if (_fromCurrency == 'USD' && _toCurrency == 'EUR') {
          _exchangeRate = 1 / 1.1;
          _convertedAmount = amount * _exchangeRate;
        } else if (_fromCurrency == 'EUR' && _toCurrency == 'MDL') {
          _exchangeRate = 19.6;
          _convertedAmount = amount * _exchangeRate;
        } else if (_fromCurrency == 'MDL' && _toCurrency == 'EUR') {
          _exchangeRate = 1 / 19.6;
          _convertedAmount = amount * _exchangeRate;
        }
      }
    });
  }

  // Metodă pentru afișarea unui dialog de eroare
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
