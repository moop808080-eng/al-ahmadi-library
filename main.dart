import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const AlAhmadiApp());

class Product {
  final String name;
  final String category;
  final int price;
  final IconData icon;
  const Product(this.name, this.category, this.price, this.icon);
}

class AlAhmadiApp extends StatelessWidget {
  const AlAhmadiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مكتبة الأحمدي',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF168B78)),
        fontFamily: 'Roboto',
      ),
      home: const StoreHome(),
    );
  }
}

class StoreHome extends StatefulWidget {
  const StoreHome({super.key});
  @override
  State<StoreHome> createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  final List<Product> products = const [
    Product('كراسة  copybook', 'أدوات مدرسية', 20, Icons.menu_book),
    Product('قلم جاف', 'أدوات مدرسية', 10, Icons.edit),
    Product('علبة ألوان', 'أدوات مدرسية', 45, Icons.palette),
    Product('دبدوب هدية', 'ألعاب وهدايا', 150, Icons.toys),
    Product('لعبة أطفال', 'ألعاب وهدايا', 85, Icons.extension),
    Product('شنطة هدايا', 'ألعاب وهدايا', 60, Icons.card_giftcard),
  ];
  final Map<int, int> cart = {};
  String category = 'الكل';

  int get total => cart.entries.fold(
      0, (sum, entry) => sum + products[entry.key].price * entry.value);
  int get count => cart.values.fold(0, (a, b) => a + b);

  Future<void> sendOrder() async {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف منتجات إلى السلة أولاً')),
      );
      return;
    }
    final lines = cart.entries.map((e) =>
        '${products[e.key].name} × ${e.value} = ${products[e.key].price * e.value} جنيه').join('\n');
    final message = 'السلام عليكم، أريد طلب المنتجات التالية من مكتبة الأحمدي:\n$lines\nالإجمالي: $total جنيه';
    final uri = Uri.parse('https://wa.me/201141086737?text=${Uri.encodeComponent(message)}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح واتساب')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shown = products.asMap().entries.where((e) =>
      category == 'الكل' || e.value.category == category).toList();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مكتبة الأحمدي', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 14),
              child: Center(child: Badge(
                label: Text('$count'),
                child: const Icon(Icons.shopping_cart_outlined, size: 27),
              )),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE4F4EF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أهلاً بك في مكتبة الأحمدي', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('أدوات مدرسية • ألعاب • هدايا'),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: ['الكل', 'أدوات مدرسية', 'ألعاب وهدايا'].map((c) =>
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: category == c,
                    onSelected: (_) => setState(() => category = c),
                  ),
                )).toList()),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: shown.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: .82,
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                itemBuilder: (context, i) {
                  final entry = shown[i];
                  final index = entry.key;
                  final p = entry.value;
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(p.icon, size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 10),
                          Text(p.name, textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          Text('${p.price} جنيه'),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: () => setState(() => cart[index] = (cart[index] ?? 0) + 1),
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text('أضف للسلة'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('السلة: $count منتج'),
                      Text('الإجمالي: $total جنيه', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    ],
                  )),
                  FilledButton.icon(
                    onPressed: sendOrder,
                    icon: const Icon(Icons.chat),
                    label: const Text('اطلب واتساب'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
