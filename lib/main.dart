import'package:flutter/material.dart';
import'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(weatherapp());
}


class weatherapp extends StatefulWidget{
  const weatherapp ({super.key});

@override
State<weatherapp> createState() => _weatherappState();
 
}
class _weatherappState extends State<weatherapp>{

@override
  void initState() {
    super.initState();
    getweather();
  }

final TextEditingController citycontroller=TextEditingController();

String cityname="chennai";
String apikey = dotenv.env['API_KEY']!;

String get url =>
    'https://api.openweathermap.org/data/2.5/weather?q=$cityname&appid=$apikey&units=metric';

double temperature=0;
double feelslike=0;
int humidity=0; 
double windspeed=0;
String condition='';
String weathericon='';
DateTime? sunrise;
DateTime? sunset;
List forecastlist=[];
List dailyforecast=[];

    Future<void> getweather()async{
      final Response=await http.get(Uri.parse(url));
      Map<String,dynamic> data=jsonDecode(Response.body);
   

      final forecasturl =
      'https://api.openweathermap.org/data/2.5/forecast?q=$cityname&appid=$apikey&units=metric';
      final forecastresponse= await http.get(Uri.parse(forecasturl));
      final forecastdata = jsonDecode(forecastresponse.body);

 
      setState(() {
       temperature=data['main']['temp'];
       feelslike=data['main']['feels_like'];
       humidity= data['main']['humidity'];
       windspeed=data['wind']['speed'];
       condition=data['weather'][0]['main'];
       weathericon=data['weather'][0]['icon'];
       sunrise = DateTime.fromMillisecondsSinceEpoch(
       data['sys']['sunrise'] * 1000,);
       sunset = DateTime.fromMillisecondsSinceEpoch(
       data['sys']['sunset'] * 1000,);
       forecastlist= forecastdata['list']; 
       dailyforecast.clear();
       for (var item in forecastlist) {
       if (item['dt_txt'].toString().contains('12:00:00')) {
       dailyforecast.add(item);
      }
    }
     
       });
   
    }
  
@override
  Widget build(BuildContext context){
    return MaterialApp(debugShowCheckedModeBanner: false,
    home: Scaffold(
    body:SafeArea(child:SingleChildScrollView(child:Column(children: [Container(height: 500,
    width: 500,
    decoration: BoxDecoration(color: Colors.blue,
    borderRadius: BorderRadius.circular(10)),
    child: Column(children: [Row(children: [
    Expanded(child: Padding(padding: EdgeInsets.all(15),
    child:SizedBox(
    height: 50,
    child: TextField(controller: citycontroller,
    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide.none),
    fillColor: Colors.white70,
    filled: true,
    hintText: "Search city...",
    hintStyle: TextStyle(color: Colors.black,)))),)),

    Padding(padding: EdgeInsets.all(10),
    child:  MaterialButton(onPressed: () async{
     String city=citycontroller.text.trim();
      if(city.isEmpty){

      }
      else{
        setState(() {
      cityname=city;
      citycontroller.clear();
        });
      }

      await getweather();
    
    },
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    color: Colors.white60,
    height: 40,
    minWidth: 20,
    child: Icon(Icons.search,
    size: 25,
    color: Colors.white,),),)
    ],),
    
   Row(children: [Padding(padding: EdgeInsets.all(15),
   child: Container(child: Row(crossAxisAlignment: CrossAxisAlignment.center,
   children: [Icon(Icons.location_pin,
   size: 40,color: Colors.white,),
   SizedBox(width: 10,),
   Column(children: [Text(cityname,
   style: TextStyle(color: Colors.white,
   fontSize: 25,
   fontWeight: FontWeight.bold),),
   Text(condition,
   style: TextStyle(color: Colors.white,
   fontWeight: FontWeight.normal))],)
   ],),),)],),

  Center(child: Column(children: [
  Image.network(
  'https://openweathermap.org/img/wn/$weathericon@2x.png',
  width: 100,
  height: 100,
  color: Colors.white,
),
  SizedBox(height: 5,),
  Text('${temperature.toStringAsFixed(1)}°C',
  style: TextStyle(color: Colors.white,
  fontSize: 50,
  fontWeight: FontWeight.bold)),
  SizedBox(height: 5,),
  Text("Feels like $feelslike",
  style: TextStyle(color: Colors.white,
  fontWeight: FontWeight.w300),)],),),
  SizedBox(height: 25,),

  Padding(padding: EdgeInsets.symmetric(horizontal: 10),
  child: Container(height: 90,padding: EdgeInsets.all(10),
  decoration: BoxDecoration(color: Colors.white12,borderRadius: BorderRadius.circular(10)),
  child: Row(children: [
  fourcard("humidity", '$humidity%', Icons.water_drop,Colors.white70),
  VerticalDivider(color: Colors.white24,),
  fourcard("wind", '$windspeed km/h', Icons.air,Colors.white70),
  VerticalDivider(color: Colors.white24,),
  fourcard("Sunrise", '${sunrise?.hour}:${sunrise?.minute}', Icons.wb_twighlight,Colors.white70),
  VerticalDivider(color: Colors.white24),
  fourcard("Sunset", '${sunset?.hour}:${sunset?.minute}', Icons.wb_sunny,Colors.white70)
  ],),),),
  
  ],),),
    
  SizedBox(height: 20),

  Row(children: [SizedBox(width: 15,),
  Text("5 Day Forecast", textAlign:TextAlign.left,
  style: TextStyle(color: Colors.black,
  fontSize: 25,
  fontWeight: FontWeight.bold),)],),

  SizedBox(height: 20,),
 
  Row(
  children: List.generate(dailyforecast.length, (index) {
  final item = dailyforecast[index];

    return forecast(
      item['dt_txt'].toString().substring(5, 10),
      item['weather'][0]['icon'],
      '${item['main']['temp'].toStringAsFixed(0)}°C',
      Colors.orange,
    );
  }),
)

       ],),)

       ),
      )
    );
  }

  Widget fourcard(name,percentage,Icons,Colors){
   return Expanded(child: 
  Column(children: [
  Icon(Icons,color: Colors,),
  Text(name,style: TextStyle(color: Colors,),),
  Text(percentage,style: TextStyle(color: Colors,),)
  ],));
  }

  Widget forecast(days,Icons,degree,Color){
  return  Expanded(child:Card(elevation: 5,
  color: Colors.white,
  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10),
  side: BorderSide.none),
  child: SizedBox(height: 130,
  width: 77,
  child: Padding(padding: EdgeInsets.all(15),
  child: Column(children: [Text(days,
  style: TextStyle(fontSize: 13,color: Colors.black),),
  SizedBox(height: 15),
  Image.network(
  'https://openweathermap.org/img/wn/$Icons@2x.png',
  width: 30,
  height: 30,
  ),
  SizedBox(height: 15,),
  Text(degree)
  ],),),)));
  }

}


