import 'package:flutter/material.dart';
import 'package:mine/services/notification_service.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isCelsiusSelected = true;
  String _selectedLanguage = 'English';
  bool _isNotificationEnabled = true;
  bool _isDarkThemeEnabled = false;
  String _selectedRefreshInterval = 'Every 30 minutes';
  late final NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    // Initialize the notification service here
    notificationService = NotificationService();
    notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection('Units', _buildUnitSelection()),
          _buildSection('Language', _buildLanguageSelection()),
          _buildSection('Notification Preferences', _buildNotificationPreferences()),
          _buildSection('Data Refresh Intervals', _buildRefreshIntervalSelection()),
          _buildSection('Theme Change', _buildThemeSwitch()),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        content,
      ],
    );
  }

  // Include other widget build methods (_buildUnitSelection, _buildLanguageSelection, etc.) here
  // No changes needed in these methods for the notification feature
  Widget _buildUnitSelection() {
    return ListTile(
      title: Text('Temperature Units'),
      trailing: DropdownButton<String>(
        value: _isCelsiusSelected ? 'Celsius' : 'Fahrenheit',
        onChanged: (newValue) {
          setState(() {
            _isCelsiusSelected = newValue == 'Celsius';
          });
        },
        items: ['Celsius', 'Fahrenheit']
            .map<DropdownMenuItem<String>>(
              (value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildLanguageSelection() {
    return ListTile(
      title: Text('Preferred Language'),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        onChanged: (newValue) {
          setState(() {
            _selectedLanguage = newValue!;
          });
        },
        items: ['English', 'Spanish', 'French']
            .map<DropdownMenuItem<String>>(
              (value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
            .toList(),
      ),
    );
  }
  Widget _buildRefreshIntervalSelection() {
    return ListTile(
      title: Text('Data Refresh Interval'),
      trailing: DropdownButton<String>(
        value: _selectedRefreshInterval,
        onChanged: (newValue) {
          setState(() {
            _selectedRefreshInterval = newValue!;
          });
        },
        items: ['Every 15 minutes', 'Every 30 minutes', 'Every hour']
            .map<DropdownMenuItem<String>>(
              (value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          ),
        )
            .toList(),
      ),
    );
  }

  Widget _buildThemeSwitch() {
    return SwitchListTile(
      title: Text('Dark Theme'),
      value: _isDarkThemeEnabled,
      onChanged: (value) {
        setState(() {
          _isDarkThemeEnabled = value;
          Provider.of<ThemeNotifier>(context, listen: false).setDarkTheme(value);
        });
      },
    );
  }

  void _triggerSevereWeatherAlertNotification() {
    notificationService.sendSevereWeatherAlertNotification();
  }

  Widget _buildNotificationPreferences() {
    return SwitchListTile(
      title: Text('Enable Notifications'),
      value: _isNotificationEnabled,
      onChanged: (value) {
        setState(() {
          _isNotificationEnabled = value;
          if (value) _triggerSevereWeatherAlertNotification();
        });
      },
    );
  }
}
