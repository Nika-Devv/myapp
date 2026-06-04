import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/weather_controller.dart';
import '../models/weather_forecast.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  final WeatherController _controller = WeatherController();
  late Future<List<WeatherForecast>> _weatherFuture;

  @override
  void initState() {
    super.initState();
    onStart();
  }

  Future<void> onStart() async {
    setState(() {
      _weatherFuture = _controller.fetchWeatherForecasts();
    });
  }

  void _refreshWeather() {
    setState(() {
      _weatherFuture = _controller.fetchWeatherForecasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Forecast'),
        actions: [
          IconButton(
            onPressed: _refreshWeather,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<WeatherForecast>>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshWeather,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No weather data available.'));
          }

          final forecasts = snapshot.data!;
          return ListView.builder(
            itemCount: forecasts.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = forecasts[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: _getWeatherIcon(item.summary),
                  title: Text(
                    DateFormat('EEEE, MMM d').format(item.date),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        item.summary ?? 'N/A',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.temperatureC}°C',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      Text(
                        '${item.temperatureF}°F',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getWeatherIcon(String? summary) {
    IconData iconData;
    Color color;

    switch (summary?.toLowerCase()) {
      case 'freezing':
      case 'bracing':
        iconData = Icons.ac_unit;
        color = Colors.lightBlueAccent;
        break;
      case 'chilly':
      case 'cool':
        iconData = Icons.cloud;
        color = Colors.blueGrey;
        break;
      case 'mild':
      case 'warm':
        iconData = Icons.wb_cloudy;
        color = Colors.orangeAccent;
        break;
      case 'balmy':
      case 'hot':
        iconData = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 'sweltering':
      case 'scorching':
        iconData = Icons.sunny;
        color = Colors.redAccent;
        break;
      default:
        iconData = Icons.wb_cloudy_outlined;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }
}
