import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:iddaa_tahminleri/services/advert-service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Iddaa Tahminleri",
      theme: ThemeData(fontFamily: 'Monospace'),
      home: AnaEkran(),
    );
  }
}

class AnaEkran extends StatefulWidget {
  @override
  _AnaEkranState createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  int currentPage = 0;
  GlobalKey bottomNavigationKey = GlobalKey();
  final AdvertService _advertService = AdvertService();

  @override
  void initState() {
    _advertService.showBanner();

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: _getPage(currentPage),
      ),
      backgroundColor: Color.fromARGB(204, 220, 226, 255),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(
              iconData: Icons.sports_soccer,
              title: "Günlük",
              onclick: () {
                final FancyBottomNavigationState fState =
                    bottomNavigationKey.currentState;
                fState.setPage(0);
              }),
          TabData(iconData: Icons.person, title: "Profil"),
          TabData(iconData: Icons.calendar_today, title: "Dün")
        ],
        initialSelection: 0,
        key: bottomNavigationKey,
        onTabChangedListener: (pos) {
          setState(() {
            currentPage = pos;
          });
        },
        circleColor: Color.fromARGB(255, 0, 149, 136),
        inactiveIconColor: Color.fromARGB(255, 0, 149, 136),
      ),
    );
  }
}

var yetkiGiris;
_getPage(int page) {
  switch (page) {
    case 0:
      return Gunluk();
    case 1:
      if (FirebaseAuth.instance.currentUser == null) {
        return AnaProfile();
      } else if (yetkiGiris == "ADMIN") {
        return AdminPanel();
      } else {
        return KullaniciProfile();
      }
      return KullaniciProfile();
    case 2:
      return Dun();
  }
}

class Dun extends StatefulWidget {
  @override
  _DunState createState() => _DunState();
}

bool kontrolcu;

class _DunState extends State<Dun> {
  final AdvertService _advertService = AdvertService();

  @override
  void initState() {
    super.initState();
    _advertService.showIntersitial();
  }

  Widget build(BuildContext context) {
    Color tfRenk = Colors.white;
    DateTime _now = DateTime.now();
    DateTime _start = DateTime(_now.year, _now.month, _now.day - 1, 0, 0);
    DateTime _end = DateTime(_now.year, _now.month, _now.day - 1, 23, 59, 59);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Maclar")
          .where("tarihSaat", isGreaterThanOrEqualTo: _start)
          .where("tarihSaat", isLessThanOrEqualTo: _end)
          .snapshots(),
      // ignore: missing_return
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Icon(
            Icons.error,
            size: 150,
            color: Colors.yellow,
          ));
        }
        // ignore: unused_local_variable
        final QuerySnapshot querySnapshot = snapshot.data;

        // ignore: missing_return
        return ListView.builder(
            padding: EdgeInsets.only(top: 120),
            itemCount: querySnapshot.size,
            itemBuilder: (context, index) {
              final map = querySnapshot.docs[index].data();
              if (map['Sonuc'] == "true") {
                tfRenk = Colors.greenAccent;
              } else if (map['Sonuc'] == "false") {
                tfRenk = Colors.redAccent;
              } else {
                tfRenk = Colors.white;
              }

              return Container(
                  child: tahminGiris(
                      map['EvS-Dep'],
                      map['tarihSaat'].toDate().toString().substring(0, 16),
                      map['TahminTuru'],
                      map['Tahmin'],
                      map['Oran'],
                      tfRenk,
                      map['MacTuru']));
            });
      },
    );
  }

  Padding tahminGiris(String macAdi, String macTarihi, String tahminTuru,
      String tahmin, String oran, Color tfrenk, String macT) {
    Icon macTuruIcon() {
      if (macT == "Futbol") {
        return Icon(
          Icons.sports_soccer,
          color: Color.fromARGB(255, 38, 78, 87),
          size: 31,
        );
      } else if (macT == "Basketbol") {
        return Icon(
          Icons.sports_basketball,
          color: Color.fromARGB(255, 38, 78, 87),
          size: 31,
        );
      } else if (macT == "Voleybol") {
        return Icon(
          Icons.sports_volleyball,
          color: Color.fromARGB(255, 38, 78, 87),
          size: 31,
        );
      }
      return Icon(
        Icons.sports_soccer,
        color: Color.fromARGB(255, 38, 78, 87),
        size: 31,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
      child: Container(
        decoration: myBorderDec(tfrenk),
        padding: const EdgeInsets.only(top: 17, left: 10, bottom: 15),
        height: 150,
        child: Column(
          children: <Widget>[
            Container(
              //icon Row
              child: Row(
                children: <Widget>[
                  macTuruIcon(),
                  SizedBox(
                    width: 10,
                  ),
                  Text(macAdi,
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 78, 87),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      )),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              //icon Row
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.calendar_today,
                    color: Color.fromARGB(255, 38, 78, 87),
                    size: 31,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(macTarihi,
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 78, 87),
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      )),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              //icon Row
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.track_changes,
                    color: Color.fromARGB(255, 38, 78, 87),
                    size: 31,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.07,
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: Center(
                      child: Text(tahminTuru,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          )),
                    ),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 38, 78, 87),
                        borderRadius: BorderRadius.circular(5)),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 38, 78, 87),
                        borderRadius: BorderRadius.circular(5)),
                    height: MediaQuery.of(context).size.width * 0.07,
                    width: MediaQuery.of(context).size.width * 0.11,
                    child: Center(
                      child: Text(tahmin,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          )),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(oran,
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 78, 87),
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KullaniciProfile extends StatefulWidget {
  @override
  _KullaniciProfileState createState() => _KullaniciProfileState();
}

class _KullaniciProfileState extends State<KullaniciProfile> {
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
          child: Align(
              child: Column(
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          Container(
            height: MediaQuery.of(context).size.width / 2,
            width: MediaQuery.of(context).size.width / 2,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 38, 78, 87),
                borderRadius: BorderRadius.circular(500)),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.5,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            "${FirebaseAuth.instance.currentUser.email.split("@").first}",
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.09,
                fontWeight: FontWeight.bold),
          ),
          Text(
            "Yuvarlak Masaya",
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
            ),
          ),
          Text(
            "Hoşgeldin",
            style:
                TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06),
          ),
          SizedBox(
            height: 80,
          ),
          RaisedButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => AnaEkran()));
            },
            child: Text("Çıkış Yap"),
          )
        ],
      ))),
    );
  }
}

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  TextEditingController kullaniciYetkiCon = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    DateTime _now = DateTime.now();
    // ignore: unused_local_variable
    DateTime _bas = DateTime(_now.year, _now.month, _now.day - 2, 0, 0);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 80,
          ),
          Container(
            height: MediaQuery.of(context).size.width / 2,
            width: MediaQuery.of(context).size.width / 2,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 38, 78, 87),
                borderRadius: BorderRadius.circular(500)),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: MediaQuery.of(context).size.width * 0.5,
            ),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminMacTahminiEkleme()));
            },
            child: Text("Maç Tahmini Ekle"),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TahminTuttumuPage()));
            },
            child: Text("Tahmin Tuttumu?"),
          ),
          RaisedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("Maclar")
                  .where("tarihSaat", isLessThanOrEqualTo: _bas)
                  .snapshots()
                  .listen((data) => data.docs.forEach((doc) {
                        FirebaseFirestore.instance
                            .collection("Maclar")
                            .doc(doc.id)
                            .delete();
                      }));
              FirebaseFirestore.instance
                  .collection("Yorumlar")
                  .where("TarihSaat", isLessThanOrEqualTo: _bas)
                  .snapshots()
                  .listen((veri) => veri.docs.forEach((dokuman) {
                        FirebaseFirestore.instance
                            .collection("Yorumlar")
                            .doc(dokuman.id)
                            .delete();
                      }));
            },
            child: Text("Firebase Temizle"),
          ),
          myTextBox("Kullanıcı Adı", kullaniciYetkiCon, "asd"),
          RaisedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("Uyeler")
                  .doc(kullaniciYetkiCon.text)
                  .update({'YetkiDurumu': "YorumYapamaz"}).then(
                      (value) => kullaniciYetkiCon.clear());
            },
            child: Text("Kullanıcı Yetki Al"),
          ),
          RaisedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("Uyeler")
                  .doc(kullaniciYetkiCon.text)
                  .update({'YetkiDurumu': "Yorum"}).then(
                      (value) => kullaniciYetkiCon.clear());
            },
            child: Text("Kullanıcı Yetki Ver"),
          ),
          RaisedButton(
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => AnaEkran()));
            },
            child: Text("Çıkış Yap"),
          )
        ],
      ),
    );
  }
}

class TahminTuttumuPage extends StatefulWidget {
  @override
  _TahminTuttumuPageState createState() => _TahminTuttumuPageState();
}

class _TahminTuttumuPageState extends State<TahminTuttumuPage> {
  TextEditingController esdepcon = TextEditingController();
  TextEditingController sonucCon = TextEditingController();
  TextEditingController tahminTurCon = TextEditingController();
  TextEditingController tahminCon = TextEditingController();

  var selectedCurrency, selectedType, tasiyici;
  List listItem = ["true", "false"];
  String sonucSecim;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(204, 220, 226, 255),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 200,
              ),
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Maclar")
                      .where("Sonuc", isEqualTo: "NULL")
                      .snapshots(),
                  // ignore: missing_return
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return CircularProgressIndicator();
                    else {
                      List<DropdownMenuItem> currencyItems = [];
                      for (int i = 0; i < snapshot.data.docs.length; i++) {
                        DocumentSnapshot snap = snapshot.data.docs[i];
                        // ignore: unused_local_variable
                        final map = snapshot.data.docs[i].data();
                        currencyItems.add(
                          DropdownMenuItem(
                            child: Text(
                              "${map['EvS-Dep']} ${map['TahminTuru']} ${map['Tahmin']} ${map['tarihSaat'].toDate().toString().split(" ").last.substring(0, 5)}",
                              style: TextStyle(color: Colors.black),
                            ),
                            value: "${snap.id}",
                          ),
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: 50.0),
                          DropdownButton(
                            items: currencyItems,
                            onChanged: (currencyValue) {
                              setState(() {
                                selectedCurrency = currencyValue;
                                esdepcon.text = selectedCurrency;
                              });
                            },
                            value: selectedCurrency,
                            isExpanded: false,
                            hint: new Text(
                              "Sonuç Girilecek Maç Seçin",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      );
                    }
                  }),
              SizedBox(
                height: 100,
              ),
              DropdownButton(
                hint: Text("Tahmin Sonucu Secin"),
                value: sonucSecim,
                onChanged: (newValue) {
                  setState(() {
                    sonucSecim = newValue;
                    sonucCon.text = sonucSecim;
                  });
                },
                items: listItem.map((valueItem) {
                  return DropdownMenuItem(
                    value: valueItem,
                    child: Text(valueItem),
                  );
                }).toList(),
              ),
              SizedBox(
                height: 100,
              ),
              RaisedButton(
                onPressed: () {
                  if (esdepcon.text == "" || sonucCon.text == "") {
                    setState(() {
                      AlertDialog alert = AlertDialog(
                          title: Text("HATA"),
                          content: Text("Hiçbir Alanı Boş Bırakamazsın."),
                          actions: [
                            FlatButton(
                              child: Text("TAMAM"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ]);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          });
                    });
                  } else {
                    FirebaseFirestore.instance
                        .collection("Maclar")
                        .doc(esdepcon.text)
                        .update({
                      'Sonuc': sonucCon.text,
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: Text("Tahmin Tuttumu?"),
              )
            ],
          ),
        ));
  }
}

class AdminMacTahminiEkleme extends StatefulWidget {
  @override
  _AdminMacTahminiEklemeState createState() => _AdminMacTahminiEklemeState();
}

class _AdminMacTahminiEklemeState extends State<AdminMacTahminiEkleme> {
  TextEditingController evsdepcon = TextEditingController();
  TextEditingController tahminturcon = TextEditingController();
  TextEditingController tahmincon = TextEditingController();
  TextEditingController orancon = TextEditingController();
  DateTime pickedDate;
  TimeOfDay time;
  TextEditingController macTuruCon = TextEditingController();
  List macTuru = [
    "Futbol",
    "Basketbol",
    "Voleybol",
  ];
  String macTuruSecim;

  @override
  void initState() {
    pickedDate = DateTime.now();
    time = TimeOfDay.now();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(204, 220, 226, 255),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 100,
            ),
            DropdownButton(
              hint: Text("Maç Türü Seçin"),
              value: macTuruSecim,
              onChanged: (newValue) {
                setState(() {
                  macTuruSecim = newValue;
                  macTuruCon.text = macTuruSecim;
                });
              },
              items: macTuru.map((valueItem) {
                return DropdownMenuItem(
                  value: valueItem,
                  child: Text(valueItem),
                );
              }).toList(),
            ),
            myTextBox("Evsahibi - Deplasman ", evsdepcon, "asd"),
            myTextBox("Tahmin Türü", tahminturcon, "asd"),
            myTextBox("Tahmin", tahmincon, "asd"),
            myTextBox("Oran", orancon, "asd"),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: ListTile(
                title: Text(
                    "Tarih: ${pickedDate.day}.${pickedDate.month}.${pickedDate.year}"),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: _pickDate,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: ListTile(
                title: Text("Saat: ${time.hour} : ${time.minute}"),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: _pickTime,
              ),
            ),
            RaisedButton(
              onPressed: () {
                if (evsdepcon.text == "" ||
                    orancon.text == "" ||
                    tahmincon.text == "" ||
                    tahminturcon.text == "" ||
                    macTuruCon.text == "" ||
                    evsdepcon.text.length > 25) {
                  setState(() {
                    AlertDialog alert = AlertDialog(
                        title: Text("HATA"),
                        content: Text(
                            "Hiçbir Alanı Boş Bırakamazsın. VEYA Evsahibi - Deplasman Alanı 25 Karakterden Fazla Olamaz"),
                        actions: [
                          FlatButton(
                            child: Text("TAMAM"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ]);
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  });
                } else {
                  FirebaseFirestore.instance.collection("Maclar").doc().set({
                    'EvS-Dep': evsdepcon.text,
                    'Oran': orancon.text,
                    'Tahmin': tahmincon.text,
                    'TahminTuru': tahminturcon.text,
                    'tarihSaat': DateTime(pickedDate.year, pickedDate.month,
                        pickedDate.day, time.hour, time.minute),
                    'Sonuc': "NULL",
                    'MacTuru': macTuruCon.text
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text("Tahmini Ekle"),
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }

  _pickDate() async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: DateTime(DateTime.now().year - 1),
        lastDate: DateTime(DateTime.now().year + 1));
    if (date != null) {
      setState(() {
        pickedDate = date;
      });
    }
  }

  _pickTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: time);
    if (t != null) {
      setState(() {
        time = t;
      });
    }
  }
}

class AnaProfile extends StatefulWidget {
  @override
  _AnaProfileState createState() => _AnaProfileState();
}

class _AnaProfileState extends State<AnaProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: RaisedButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Profile()));
        },
        child: Text(
          "Oturum Aç",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.06),
        ),
      ),
    ));
  }
}

BoxDecoration myBorderDec(Color renk) {
  return BoxDecoration(
      color: renk,
      border: Border.all(
        color: Color.fromARGB(255, 38, 78, 87),
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(5));
}

class Gunluk extends StatefulWidget {
  @override
  _GunlukState createState() => _GunlukState();
}

class _GunlukState extends State<Gunluk> {
  @override
  Widget build(BuildContext context) {
    DateTime _now = DateTime.now();
    DateTime _start = DateTime(_now.year, _now.month, _now.day, 0, 0);
    DateTime _end = DateTime(_now.year, _now.month, _now.day, 23, 59, 59);
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Maclar")
          .where("tarihSaat", isGreaterThanOrEqualTo: _start)
          .where("tarihSaat", isLessThanOrEqualTo: _end)
          .snapshots(),
      // ignore: missing_return
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Icon(
            Icons.error,
            size: 150,
            color: Colors.yellow,
          ));
        }
        // ignore: unused_local_variable
        final QuerySnapshot querySnapshot = snapshot.data;

        // ignore: missing_return
        return ListView.builder(
            padding: EdgeInsets.only(top: 120),
            itemCount: querySnapshot.size,
            itemBuilder: (context, index) {
              final map = querySnapshot.docs[index].data();

              return Container(
                  child: tahminGiris(
                      map['EvS-Dep'],
                      map['tarihSaat'].toDate().toString().substring(0, 16),
                      map['TahminTuru'],
                      map['Tahmin'],
                      map['Oran'],
                      querySnapshot.docs[index].id,
                      map['MacTuru']));
            });
      },
    );
  }

  Padding tahminGiris(String macAdi, String macTarihi, String tahminTuru,
      String tahmin, String oran, String macYorum, String macT) {
    Icon macTuruIcon() {
      if (macT == "Futbol") {
        return Icon(
          Icons.sports_soccer,
          color: Color.fromARGB(255, 38, 78, 87),
          size: 31,
        );
      } else if (macT == "Basketbol") {
        return Icon(
          Icons.sports_basketball,
          color: Color.fromARGB(255, 38, 78, 87),
          size: 31,
        );
      } else if (macT == "Voleybol") {
        return Icon(
          Icons.sports_volleyball,
          color: Color.fromARGB(255, 38, 78, 87),
          size: 31,
        );
      }
      return Icon(
        Icons.sports_soccer,
        color: Color.fromARGB(255, 38, 78, 87),
        size: 31,
      );
    }

    return Padding(
        padding: const EdgeInsets.only(left: 25, right: 25, bottom: 15),
        child: InkWell(
            child: Container(
              decoration: myBorderDec(Colors.white),
              padding: const EdgeInsets.only(top: 17, left: 10, bottom: 15),
              height: 150,
              child: Column(
                children: <Widget>[
                  Container(
                    //icon Row
                    child: Row(
                      children: <Widget>[
                        macTuruIcon(),
                        SizedBox(
                          width: 10,
                        ),
                        Text(macAdi,
                            style: TextStyle(
                              color: Color.fromARGB(255, 38, 78, 87),
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    //icon Row
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          color: Color.fromARGB(255, 38, 78, 87),
                          size: 31,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(macTarihi,
                            style: TextStyle(
                              color: Color.fromARGB(255, 38, 78, 87),
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    //icon Row
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.track_changes,
                          color: Color.fromARGB(255, 38, 78, 87),
                          size: 31,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.width * 0.07,
                          width: MediaQuery.of(context).size.width * 0.38,
                          child: Center(
                            child: Text(tahminTuru,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                )),
                          ),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 38, 78, 87),
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 38, 78, 87),
                              borderRadius: BorderRadius.circular(5)),
                          height: MediaQuery.of(context).size.width * 0.07,
                          width: MediaQuery.of(context).size.width * 0.11,
                          child: Center(
                            child: Text(tahmin,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(oran,
                            style: TextStyle(
                              color: Color.fromARGB(255, 38, 78, 87),
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                            ))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              // ignore: unrelated_type_equality_checks
              if (FirebaseAuth.instance.currentUser == null) {
                setState(() {
                  AlertDialog alert = AlertDialog(
                      title: Text("OTURUM AÇ"),
                      content: Text(
                          "Maçlar hakkında yorum yapmak için giriş yapmalısın."),
                      actions: [
                        FlatButton(
                          child: Text("TAMAM"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ]);
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      });
                });
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => YorumlarSayfasi(
                              macYorumPage: macYorum,
                            )));
              }
            }));
  }
}

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController girisKullaniciAdiCon = TextEditingController();
  TextEditingController girisSifreCon = TextEditingController();
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(204, 220, 226, 255),
        body: SingleChildScrollView(
          child: Column(children: <Widget>[
            SizedBox(
              height: 100,
            ),
            Container(
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                  color: Color.fromARGB(255, 38, 78, 87),
                  borderRadius: BorderRadius.circular(500)),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
            myTextBox("Kullanıcı Adı", girisKullaniciAdiCon, "asd"),
            myTextBox("Şifre", girisSifreCon, "pass"),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 120,
                  child: RaisedButton(
                    onPressed: () async {
                      try {
                        final UserCredential userCredential =
                            await _auth.signInWithEmailAndPassword(
                                email:
                                    '${girisKullaniciAdiCon.text}@hotmail.com',
                                password: girisSifreCon.text);
                        // ignore: unused_local_variable
                        final User user = userCredential.user;
                        FirebaseFirestore.instance
                            .collection("Uyeler")
                            .doc(
                                "${FirebaseAuth.instance.currentUser.email.toString()}")
                            .get()
                            .then((value) =>
                                yetkiGiris = value.data()['YetkiDurumu']);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AnaEkran()));
                      } catch (e) {
                        setState(() {
                          AlertDialog alert = AlertDialog(
                              title: Text("HATA"),
                              content: Text("Kullanıcı adı veya şifre yanlış."),
                              actions: [
                                FlatButton(
                                  child: Text("TAMAM"),
                                  onPressed: () {
                                    girisSifreCon.clear();
                                    Navigator.of(context).pop();
                                  },
                                )
                              ]);
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        });
                      }
                    },
                    child: Text("Giriş"),
                  ),
                ),
                SizedBox(width: 25),
                SizedBox(
                  width: 120,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KayitOlPage(),
                        ),
                      );
                    },
                    child: Text("Kayıt Ol"),
                  ),
                ),
              ],
            )
          ]),
        ));
  }
}

Padding myTextBox(String textBoxAdi, TextEditingController con, String pass) {
  if (pass == "pass") {
    return Padding(
        padding: const EdgeInsets.only(top: 20, left: 55, right: 55),
        child: TextField(
          decoration: new InputDecoration(
              border: new OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.yellow)),
              labelText: textBoxAdi),
          controller: con,
          obscureText: true,
          obscuringCharacter: "*",
        ));
  } else {
    return Padding(
        padding: const EdgeInsets.only(top: 20, left: 55, right: 55),
        child: TextField(
          decoration: new InputDecoration(
              border: new OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.yellow)),
              labelText: textBoxAdi),
          controller: con,
        ));
  }
}

class KayitOlPage extends StatefulWidget {
  @override
  _KayitOlPageState createState() => _KayitOlPageState();
}

class _KayitOlPageState extends State<KayitOlPage> {
  TextEditingController kayitOlKullaniciAdiCon = TextEditingController();
  TextEditingController kayitOlSifreCon = TextEditingController();
  TextEditingController kayitOlReSifreCon = TextEditingController();

  // ignore: unused_field
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromARGB(204, 220, 226, 255),
        body: ListView(scrollDirection: Axis.vertical, children: <Widget>[
          Container(
            child: Column(children: <Widget>[
              SizedBox(
                height: 80,
              ),
              Container(
                height: MediaQuery.of(context).size.width / 2,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 38, 78, 87),
                    borderRadius: BorderRadius.circular(500)),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.5,
                ),
              ),
              myTextBox("Kullanıcı Adı", kayitOlKullaniciAdiCon, "asd"),
              myTextBox("Şifre", kayitOlSifreCon, "pass"),
              myTextBox("Tekrar-Şifre", kayitOlReSifreCon, "pass"),
              SizedBox(
                height: 20,
              ),
              SizedBox(width: 25),
              SizedBox(
                width: 120,
                child: RaisedButton(
                  onPressed: () async {
                    if (kayitOlSifreCon.text == kayitOlReSifreCon.text) {
                      try {
                        // ignore: unused_local_variable
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                                email:
                                    '${kayitOlKullaniciAdiCon.text}@hotmail.com',
                                password: kayitOlSifreCon.text);

                        FirebaseFirestore.instance
                            .collection("Uyeler")
                            .doc('${kayitOlKullaniciAdiCon.text}@hotmail.com')
                            .set({
                          'KullaniciAdi':
                              '${kayitOlKullaniciAdiCon.text}@hotmail.com',
                          'Sifre': kayitOlSifreCon.text,
                          'UyelikTarihi': DateTime.now(),
                          'YetkiDurumu': "Yorum"
                        });

                        Navigator.of(context).pop();
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'weak-password') {
                          setState(() {
                            AlertDialog alert = AlertDialog(
                                title: Text("HATA"),
                                content: Text(
                                    "Şifreniz en az 6 karakterli olmalıdır."),
                                actions: [
                                  FlatButton(
                                    child: Text("TAMAM"),
                                    onPressed: () {
                                      kayitOlSifreCon.clear();
                                      kayitOlReSifreCon.clear();
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ]);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                });
                          });
                        } else if (e.code == 'email-already-in-use') {
                          setState(() {
                            AlertDialog alert = AlertDialog(
                                title: Text("HATA"),
                                content:
                                    Text("Kullanıcı adı zaten kullanılıyor."),
                                actions: [
                                  FlatButton(
                                    child: Text("TAMAM"),
                                    onPressed: () {
                                      kayitOlSifreCon.clear();
                                      kayitOlReSifreCon.clear();
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ]);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                });
                          });
                        } else {
                          setState(() {
                            AlertDialog alert = AlertDialog(
                                title: Text("HATA"),
                                content:
                                    Text("Kullanıcı adı zaten kullanılıyor."),
                                actions: [
                                  FlatButton(
                                    child: Text("TAMAM"),
                                    onPressed: () {
                                      kayitOlSifreCon.clear();
                                      kayitOlReSifreCon.clear();
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ]);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return alert;
                                });
                          });
                        }
                      } catch (e) {
                        print("HATA");
                      }
                    } else {
                      setState(() {
                        AlertDialog alert = AlertDialog(
                            title: Text("HATA"),
                            content: Text("Şifreler uyuşmuyor."),
                            actions: [
                              FlatButton(
                                child: Text("TAMAM"),
                                onPressed: () {
                                  kayitOlSifreCon.clear();
                                  kayitOlReSifreCon.clear();
                                  Navigator.of(context).pop();
                                },
                              )
                            ]);
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            });
                      });
                    }
                  },
                  child: Text("Kayıt Ol"),
                ),
              ),
            ]),
          )
        ]));
  }
}

class YorumlarSayfasi extends StatefulWidget {
  final String macYorumPage;

  const YorumlarSayfasi({Key key, this.macYorumPage}) : super(key: key);

  @override
  _YorumlarSayfasiState createState() => _YorumlarSayfasiState();
}

class _YorumlarSayfasiState extends State<YorumlarSayfasi> {
  final String kullaniciAdi =
      FirebaseAuth.instance.currentUser.email.toString().split("@").first;
  // ignore: unused_field
  CollectionReference _ref;
  TextEditingController yorumYap = TextEditingController();
  var yetkiKarar;
  @override
  void initState() {
    _ref = FirebaseFirestore.instance.collection('Yorumlar');
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(204, 220, 226, 255),
      body: ListView(
        reverse: true,
        children: <Widget>[
          Container(
            alignment: Alignment.bottomRight,
            margin: new EdgeInsets.only(right: 25),
            child: RaisedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("Uyeler")
                    .doc(
                        "${FirebaseAuth.instance.currentUser.email.toString()}")
                    .get()
                    .then((value) => yetkiKarar = value.data()['YetkiDurumu']);
                print(yetkiKarar);
                if (yetkiKarar == "Yorum" || yetkiKarar == "ADMIN") {
                  FirebaseFirestore.instance
                      .collection("Yorumlar")
                      .doc(DateTime.now().toString())
                      .set({
                    'YorumYapan':
                        FirebaseAuth.instance.currentUser.email.toString(),
                    'Yorum': yorumYap.text,
                    'TarihSaat': DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        DateTime.now().hour,
                        DateTime.now().minute),
                    'YorumYapilanMac': widget.macYorumPage.toString()
                  }).then((value) => yorumYap.clear());
                } else {
                  setState(() {
                    AlertDialog alert = AlertDialog(
                        title: Text("HATA"),
                        content: Text("Yorum Yapma Yetkiniz Alınmıştır."),
                        actions: [
                          FlatButton(
                            child: Text("TAMAM"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ]);
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return alert;
                        });
                  });
                }
              },
              child: Text("Yorum Yap"),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(left: 25, right: 25, top: 5),
              child: Container(
                color: Colors.white,
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 21,
                  ),
                  controller: yorumYap,
                ),
              )),
          SizedBox(
            height: 40,
          ),
          StreamBuilder(
              stream: _ref
                  .where('YorumYapilanMac',
                      isEqualTo: widget.macYorumPage.toString())
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData)
                  return CircularProgressIndicator();
                else {
                  return Column(
                    children: snapshot.data.docs
                        .map((document) => yorumEkle(
                            document['YorumYapan'],
                            document['Yorum'],
                            document['TarihSaat']
                                .toDate()
                                .toString()
                                .split(" ")
                                .last
                                .substring(0, 5),
                            document.id))
                        .toList(),
                  );
                }
              }),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Padding yorumEkle(
      String kullaniciAdi, String aciklama, String saat, var doc) {
    var silmeTusu;
    if (kullaniciAdi == FirebaseAuth.instance.currentUser.email.toString()) {
      silmeTusu = Icon(
        Icons.delete,
        color: Colors.red,
      );
    } else {
      silmeTusu = Container();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
      child: Container(
        constraints: BoxConstraints(maxHeight: double.infinity),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Column(
            children: <Widget>[
              new Align(
                alignment: Alignment.topLeft,
                child: Text(kullaniciAdi.toString().split("@").first,
                    style: TextStyle(
                      color: Color.fromARGB(255, 38, 78, 87),
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width * 0.039,
                    )),
              ),
              SizedBox(
                height: 3,
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width / 1.28,
                    child: new Align(
                      alignment: Alignment.topLeft,
                      child: Text(aciklama,
                          style: TextStyle(
                            color: Color.fromARGB(255, 38, 78, 87),
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          )),
                    ),
                  ),
                  InkWell(
                    child: new Align(
                      alignment: Alignment.centerRight,
                      child: silmeTusu,
                    ),
                    onTap: () {
                      if (kullaniciAdi ==
                          FirebaseAuth.instance.currentUser.email.toString()) {
                        FirebaseFirestore.instance
                            .collection("Yorumlar")
                            .doc(doc)
                            .delete();

                        setState(() {
                          AlertDialog alert = AlertDialog(
                              title: Text("İşlem Başarılı"),
                              content: Text("Yorumunuz Silidi"),
                              actions: [
                                FlatButton(
                                  child: Text("TAMAM"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ]);
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              });
                        });
                      }
                    },
                  ),
                ],
              ),
              new Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  saat,
                  style: TextStyle(
                      color: Color.fromARGB(255, 38, 78, 87),
                      fontSize: MediaQuery.of(context).size.width * 0.04),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
