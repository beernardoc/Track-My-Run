import 'package:flutter/material.dart';
import 'package:projeto/model/Weather_model.dart';
import 'package:projeto/service/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({Key? key}) : super(key: key);

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
    

    switch (description.toLowerCase()) {
      case 'overcast clouds':
        return 'assets/lottie/cloud.json'; 
      case 'mist':
        return 'assets/lottie/mist.json';
      case 'smoke':
        return 'assets/lottie/smoke.json';
      case 'haze':
        return 'assets/lottie/haze.json';
      case 'fog':
        return 'assets/lottie/fog.json';
      case 'rain':
        return 'assets/lottie/rain.json';
      case 'drizzle':
        return 'assets/lottie/drizzle.json';
      case 'thunder':
        return 'assets/lottie/thunder.json';
      default:
        return 'assets/lottie/sunny.json';
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
            if (_weather != null) // Verifica se _weather não é nulo antes de acessar seus atributos
              Text(_weather!.cityName), // Exibe o nome da cidade se _weather não for nulo

              Lottie.asset(getWeatherAnimation(_weather!.description), height: 400, width: 400),
          
            if (_weather != null)
              Text('${_weather!.temperature.round()}°C'), // Exibe a temperatura se _weather não for nulo
            if (_weather == null)
              Text('Loading...'), // Exibe 'Loading...' se _weather for nulo
            if (_weather != null)
              Text(_weather!.description), // Exibe a descrição do tempo se _weather não for nulo
          ],
        ),
      ),
    );
  }
}