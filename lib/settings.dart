import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app_dvm/models.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';


class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _dropdownValue1 = 'select';
  String _dropdownValue2 = 'select';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    void dropdownCallback(String? selectedValue) {
      if (selectedValue is String) {
        setState(() {
          _dropdownValue1 = selectedValue!;
        });
        if (selectedValue == 'light') {
          AdaptiveTheme.of(context).setLight();
        } else if (selectedValue == 'dark') {
          AdaptiveTheme.of(context).setDark();
        } else if (selectedValue == 'system') {
          AdaptiveTheme.of(context).setSystem();
        }
        Navigator.pop(context, {'units': _dropdownValue2, 'theme': selectedValue});
      }
    }

    void dropdownCallback2(String? selectedValue) {
      if (selectedValue is String) {
        setState(() {
          _dropdownValue2 = selectedValue!;
        });
        if (selectedValue == 'celsius') {
          AppState.selectedTemperatureUnit = 'celsius';
        } else if (selectedValue == 'fahrenheit') {
          AppState.selectedTemperatureUnit = 'fahrenheit';
        }
        Navigator.pop(context, {'units': selectedValue, 'theme': _dropdownValue1});
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Container(
            height: size.height,
            width: size.width,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Theme",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[600] ?? Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                      child: DropdownButton<String>(
                        isDense: true,
                        value: _dropdownValue1,
                        onChanged: dropdownCallback,
                        items: const [
                          DropdownMenuItem(child: Text("Select Theme"), value: "select"),
                          DropdownMenuItem(child: Text("Light"), value: "light"),
                          DropdownMenuItem(child: Text("Dark"), value: "dark"),
                          DropdownMenuItem(child: Text("System"), value: "system"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Units",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[600] ?? Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.fromLTRB(20, 15, 10, 15),
                      child: DropdownButton<String>(
                        isDense: true,
                        value: _dropdownValue2,
                        onChanged: dropdownCallback2,
                        items: const [
                          DropdownMenuItem(
                              child: Text("Select units"), value: "select"),
                          DropdownMenuItem(
                              child: Text("Celsius"), value: "celsius"),
                          DropdownMenuItem(
                              child: Text("Fahrenheit"), value: "fahrenheit"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
