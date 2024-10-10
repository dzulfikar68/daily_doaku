import 'package:flutter/material.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';

// Model Doa
class Doa {
  final String id;
  final String doa;
  final String ayat;
  final String latin;
  final String artinya;

  Doa({required this.id, required this.doa, required this.ayat, required this.latin, required this.artinya});

  factory Doa.fromJson(Map<String, dynamic> json) {
    return Doa(
      id: json['id'],
      doa: json['doa'],
      ayat: json['ayat'],
      latin: json['latin'],
      artinya: json['artinya'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doa Harian',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: DoaListPage(),
    );
  }
}

Color getRandomColor() {
  Random random = Random();
  int red = random.nextInt(256 - 128) + 128;   // 128 - 255
  int green = random.nextInt(256 - 128) + 128; // 128 - 255
  int blue = random.nextInt(256 - 128) + 128;  // 128 - 255
  return Color.fromARGB(255, red, green, blue);
}

class DoaListPage extends StatefulWidget {
  @override
  _DoaListPageState createState() => _DoaListPageState();
}

class _DoaListPageState extends State<DoaListPage> {

  List<Doa>? doas; // Menyimpan data doa
  bool isLoading = true; // Status loading

  @override
  void initState() {
    super.initState();
    fetchDoa(); // Memanggil fungsi fetchDoa saat inisialisasi
  }

  Future<void> fetchDoa() async {
    try {
      final response = await http.get(Uri.parse('https://doa-doa-api-ahmadramadhan.fly.dev/api/'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        setState(() {
          doas = jsonResponse.map((doa) => Doa.fromJson(doa)).toList();
          isLoading = false; // Update status loading
        });
      } else {
        throw Exception('Failed to load doa');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // Update status loading jika terjadi error
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Doa Harian',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      body: isLoading // Menggunakan status loading untuk menampilkan UI
          ? Center(child: CircularProgressIndicator())
          : doas != null && doas!.isNotEmpty
          ? ListView.builder(
        itemCount: doas!.length,
        itemBuilder: (context, index) {
          return Container(
            color: getRandomColor(), // Warna latar belakang acak
            child: ListTile(
              title: Text(
                doas![index].doa,
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                doas![index].latin,
                style: TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoaDetailPage(doa: doas![index]),
                  ),
                );
              },
            ),
          );
        },
      )
          : Center(child: Text('Tidak ada data')),
    );
  }

}

class DoaDetailPage extends StatefulWidget {
  final Doa doa;

  DoaDetailPage({required this.doa});

  @override
  _DoaDetailPageState createState() => _DoaDetailPageState();
}

class _DoaDetailPageState extends State<DoaDetailPage> {
  final FlutterTts flutterTts = FlutterTts();

  Future _speak(String text) async {
    flutterTts.setLanguage("id-ID");
    await flutterTts.speak(text);
  }

  Future _speakArabic(String text) async {
    flutterTts.setLanguage("ar-SA");
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    Color baseColor = getRandomColor();
    Color lighterColor = Color.alphaBlend(Colors.white.withOpacity(0.5), baseColor);
    return Scaffold(
      appBar: AppBar(title: Text(
          'Detail Doa',
          style: TextStyle(color: Colors.black),  // Mengatur warna teks title
        ),
        backgroundColor: Colors.white,),
      body: Container(
        color: baseColor, // Warna latar belakang acak
        child: SingleChildScrollView( // Tambahkan ini
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doa.doa, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                SizedBox(height: 10),
                Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Warna latar belakang
                      borderRadius: BorderRadius.circular(20), // Membulatkan sudut
                    ),
                    padding: EdgeInsets.all(8.0),
                    // color: Colors.white, // Warna latar belakang acak
                    child:Text(widget.doa.ayat, style: TextStyle(fontSize: 20, color: Colors.blue))
                ),
                SizedBox(height: 10),
                Text(widget.doa.latin, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black)),
                SizedBox(height: 10),
                Container(
                    decoration: BoxDecoration(
                      color: lighterColor, // Warna latar belakang
                      borderRadius: BorderRadius.circular(20), // Membulatkan sudut
                    ),
                    padding: EdgeInsets.all(8.0),
                    // color: Colors.white, // Warna latar belakang acak
                    child: Text(widget.doa.artinya, style: TextStyle(fontSize: 18, color: Colors.black))
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    _speakArabic(widget.doa.ayat);
                  },
                  icon: Icon(Icons.speaker_phone),  // Ikon yang akan ditampilkan
                  label: Text('Dengarkan Doa (Arabic)'),  // Teks di dalam tombol
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _speak(widget.doa.artinya);
                  },
                  icon: Icon(Icons.speaker_notes_outlined),  // Ikon yang akan ditampilkan
                  label: Text('Dengarkan Terjemahan'),  // Teks di dalam tombol
                )
              ],
            ),
          ),
        )
      )
    );
  }
}