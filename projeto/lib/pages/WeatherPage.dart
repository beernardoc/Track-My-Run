import 'package:flutter/material.dart';
import 'package:projeto/model/Weather_model.dart';
import 'package:projeto/service/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}


class _WeatherPageState extends State<WeatherPage> {

  final _weatherService = WeatherService("60a8e144d61c18ae08e66dae887be8df");
  Weather? _weather;

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();

    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    }
    catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String description) {
    print(_weather!.description);

    switch (description.toLowerCase()) {
      case 'overcast clouds':
        return 'assets/lottie/cloud.json'; 
      case 'clear sky':
        return 'assets/lottie/sunny.json';
      case 'rain':
        return 'assets/lottie/rain.json';
      case 'thunder':
        return 'assets/lottie/thunder.json';
      case 'moderate rain':
        return 'assets/lottie/moderate_rain.json';
      default:
        return 'assets/lottie/default.json';
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center( 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_weather != null)
              Column(
                children: [
                  Text(_weather!.cityName, style: const TextStyle(fontSize: 24)),
                  
                  Lottie.asset(getWeatherAnimation(_weather!.description), width: 200, height: 200),
                  Text('${_weather!.temperature.round()}°C', style: const TextStyle(fontSize: 24)),
                  Text(_weather!.description, style: const TextStyle(fontSize: 24)),
                ],
              ),
            if (_weather == null)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}