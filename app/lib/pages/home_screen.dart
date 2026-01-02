import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../widgets/product_card.dart';
import '../widgets/reviewTile.dart';
import 'scan_screen.dart';
// import 'profile_screen.dart';
import 'home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Isso garante que o código rode logo após a tela ser desenhada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<HomeController>(context, listen: false);
      controller.loadAll();
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<HomeController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "BEAUTY SCORE",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Botão escanear
                Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF758C), Color(0xFFFF7EB3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.camera_alt_outlined, size: 24),
                      label: const Text(
                        "Escanear Produto",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ScanScreen()),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Produtos em destaque
                const Text(
                  "Produtos em Destaque",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 230,
                  child: controller.isLoadingProducts
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.highlightedProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: controller.highlightedProducts[index]);
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Últimas avaliações
                const Text(
                  "Últimas Avaliações",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                controller.isLoadingReviews
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  children: controller.latestReviews
                      .map((review) => ReviewTile(review: review))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Escanear"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: "Meus Produtos"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Perfil"),
        ],
      ),
    );
  }
}
