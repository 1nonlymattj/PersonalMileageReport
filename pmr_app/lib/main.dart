import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/settings_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StartupWidget());
}

class StartupWidget extends StatelessWidget {
  const StartupWidget({super.key});

  Future<bool> _loadThemePreference() async {
    try {
      return await ThemePreferences.getTheme();
    } catch (e) {
      return false; // Fallback to default theme if error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _loadThemePreference(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        } else {
          return MileageApp(isDarkMode: snapshot.data ?? false);
        }
      },
    );
  }
}

class MileageApp extends StatefulWidget {
  final bool isDarkMode;
  const MileageApp({super.key, required this.isDarkMode});

  @override
  _MileageAppState createState() => _MileageAppState();
}

class _MileageAppState extends State<MileageApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
    ThemePreferences.setTheme(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mileage Reporting Tool',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home:
          MileageScreen(onThemeChanged: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class MileageScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool isDarkMode;

  const MileageScreen(
      {super.key, required this.onThemeChanged, required this.isDarkMode});

  @override
  _MileageScreenState createState() => _MileageScreenState();
}

class _MileageScreenState extends State<MileageScreen> {
  final TextEditingController _startingMileageController =
      TextEditingController();
  final TextEditingController _endingMileageController =
      TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  String _statusMessage = '';
  String _selectedOption = 'Mileage';

  final String scriptUrl =
      'https://script.google.com/macros/s/AKfycbzDlHuOq8lYiIXLmFVddySJZWatHuGkElZ__f-gVo7oofMVxWO-LrZxOOlJAg_xAch12Q/exec';

  Future<void> _submitData() async {
    String formattedDate = DateTime.now().toIso8601String().split('T')[0];
    Map<String, String> formData = {'date': formattedDate};

    if (_selectedOption == 'Mileage') {
      int? startingMileage = int.tryParse(_startingMileageController.text);
      int? endingMileage = int.tryParse(_endingMileageController.text);

      if (startingMileage == null ||
          endingMileage == null ||
          endingMileage <= startingMileage) {
        _showDialog('Invalid Input',
            'Please enter valid starting and ending mileage values.');
        return;
      }

      int mileageDifference = endingMileage - startingMileage;
      formData['mileage'] = mileageDifference.toString();
    } else {
      String type = _typeController.text;
      String cost = _costController.text;

      if (type.isEmpty ||
          cost.isEmpty ||
          double.tryParse(cost) == null ||
          double.parse(cost) <= 0) {
        _showDialog('Invalid Input', 'Please enter a valid type and cost.');
        return;
      }

      formData['type'] = type;
      formData['cost'] = cost;
    }

    fetchFormData(formData).then((success) {
      if (success) {
        setState(() {
          _statusMessage = _selectedOption == 'Mileage'
              ? 'Mileage of ${formData['mileage']} miles has been submitted successfully!'
              : '${formData['type']}: \\${formData['cost']} has been submitted successfully!';
        });

        Future.delayed(Duration(seconds: 3), () {
          setState(() {
            _statusMessage = '';
          });
        });

        _showDialog('Success', _statusMessage);
        _startingMileageController.clear();
        _endingMileageController.clear();
        _typeController.clear();
        _costController.clear();
      } else {
        _showDialog('Error', 'Failed to submit data.');
      }
    }).catchError((error) {
      if (!mounted) return;
      _showDialog('Error', 'Failed to submit data. Please try again.');
    });
  }

  Future<bool> fetchFormData(Map<String, String> formData) {
    return http.post(Uri.parse(scriptUrl), body: formData).then((response) {
      return response.statusCode == 200;
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          onThemeChanged: widget.onThemeChanged,
          isDarkMode: widget.isDarkMode,
        ),
      ),
    );
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mileage Reporting Tool'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DropdownButton<String>(
              value: _selectedOption,
              items: ['Mileage', 'Maintenance and Repairs'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedOption = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            if (_selectedOption == 'Mileage')
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: TextField(
                      controller: _startingMileageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Starting Mileage',
                          border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: TextField(
                      controller: _endingMileageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Ending Mileage',
                          border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            if (_selectedOption == 'Maintenance and Repairs')
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: TextField(
                      controller: _typeController,
                      decoration: InputDecoration(
                          labelText: 'Type', border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: TextField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Cost', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ElevatedButton(onPressed: _submitData, child: Text('Submit')),
            SizedBox(height: 20),
            Text(_statusMessage,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
