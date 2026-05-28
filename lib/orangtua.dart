import 'package:flutter/material.dart';

void main() {
  runApp(const PortalWaliApp());
}

class PortalWaliApp extends StatelessWidget {
  const PortalWaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Portal Wali Santri',
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        scaffoldBackgroundColor: const Color(0xfff4f7f6),
      ),
      home: const DashboardWaliPage(),
    );
  }
}

class DashboardWaliPage extends StatefulWidget {
  const DashboardWaliPage({super.key});

  @override
  State<DashboardWaliPage> createState() => _DashboardWaliPageState();
}

class _DashboardWaliPageState extends State<DashboardWaliPage> {

  int currentIndex = 0;

  final List<String> menu = [
    "Jajan",
    "SPP",
    "Izin",
    "Hafalan",
    "Nilai",
    "Biodata"
  ];

  final List<IconData> icons = [
    Icons.account_balance_wallet,
    Icons.calendar_month,
    Icons.exit_to_app,
    Icons.menu_book,
    Icons.bar_chart,
    Icons.badge,
  ];

  final Color primaryColor = const Color(0xff0f5132);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const TransferModal(),
          );
        },
        icon: const Icon(Icons.send),
        label: const Text("Lapor Transfer"),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          setState(() {
            currentIndex = i;
          });
        },
        items: [
          for (int i = 0; i < menu.length; i++)
            BottomNavigationBarItem(
              icon: Icon(icons[i]),
              label: menu[i],
            ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [

            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff0f5132),
                    const Color(0xff146c43),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [

                  Align(
                    alignment: Alignment.topRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.settings,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Ahmad Fauzan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Kobong Al-Fatih | Kelas 2",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.power_settings_new),
                    label: const Text("Keluar"),
                  )
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    // SALDO
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [

                            const Text(
                              "Sisa Uang Jajan",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "Rp 350.000",
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Jajan Hari Ini: Rp 15.000",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ALERT
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [

                          Icon(
                            Icons.local_hospital,
                            color: Colors.red,
                            size: 40,
                          ),

                          SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "PEMBERITAHUAN PENTING!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),

                                SizedBox(height: 5),

                                Text(
                                  "Anak Anda sedang dirawat di Klinik Pesantren.",
                                  style: TextStyle(
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // RIWAYAT TRANSAKSI
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Riwayat Uang Jajan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    transaksiItem(
                      masuk: true,
                      nominal: "50.000",
                      tanggal: "25 Mei 2026",
                      keterangan: "Transfer Orang Tua",
                    ),

                    transaksiItem(
                      masuk: false,
                      nominal: "15.000",
                      tanggal: "26 Mei 2026",
                      keterangan: "Jajan Kantin",
                    ),

                    transaksiItem(
                      masuk: false,
                      nominal: "10.000",
                      tanggal: "27 Mei 2026",
                      keterangan: "Fotokopi",
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transaksiItem({
    required bool masuk,
    required String nominal,
    required String tanggal,
    required String keterangan,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          masuk ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            masuk ? Icons.arrow_downward : Icons.arrow_upward,
            color: masuk ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          masuk ? "Uang Masuk" : "Pengeluaran",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("$tanggal • $keterangan"),
        trailing: Text(
          "${masuk ? '+' : '-'} Rp $nominal",
          style: TextStyle(
            color: masuk ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class TransferModal extends StatelessWidget {
  const TransferModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Lapor Bukti Transfer",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [

                    Text(
                      "Transfer ke Rekening:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "BSI 7123-456-789",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text("a.n Yayasan Pesantren Nusantara")
                  ],
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  hintText: "Nominal Transfer",
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                decoration: InputDecoration(
                  hintText: "Catatan Tambahan",
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "KIRIM KE BENDAHARA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}