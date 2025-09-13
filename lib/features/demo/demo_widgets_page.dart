import 'package:flutter/material.dart';
import '../../core/widgets/circular_progress_card.dart';
import '../../core/widgets/confetti_widget.dart';
import '../../core/widgets/loading_widgets.dart';
import '../../core/widgets/animated_widgets.dart';
import '../../core/widgets/animated_page_transitions.dart';

class DemoWidgetsPage extends StatefulWidget {
  const DemoWidgetsPage({Key? key}) : super(key: key);

  @override
  State<DemoWidgetsPage> createState() => _DemoWidgetsPageState();
}

class _DemoWidgetsPageState extends State<DemoWidgetsPage> {
  double _progressValue = 0.75;
  int _counterValue = 1250;
  bool _showLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'FinanceAI UI Demo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Progress Cards'),
            const SizedBox(height: 16),
            
            // Circular Progress Cards
            CircularProgressCard(
              title: 'Budget du mois',
              subtitle: 'Dépenses totales',
              progress: _progressValue,
              amount: '€2,450',
              totalAmount: '€3,000',
              icon: Icons.account_balance_wallet,
              gradientColors: const [Color(0xFF667eea), Color(0xFF764ba2)],
              onTap: () {
                setState(() {
                  _progressValue = (_progressValue + 0.1).clamp(0.0, 1.0);
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Mini Progress Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                MiniCircularProgressCard(
                  title: 'Épargne',
                  progress: 0.65,
                  value: '€650',
                  icon: Icons.savings,
                  color: Colors.green,
                ),
                MiniCircularProgressCard(
                  title: 'Investissement',
                  progress: 0.45,
                  value: '€1,200',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
                MiniCircularProgressCard(
                  title: 'Objectifs',
                  progress: 0.80,
                  value: '4/5',
                  icon: Icons.flag,
                  color: Colors.orange,
                ),
                MiniCircularProgressCard(
                  title: 'Cashback',
                  progress: 0.30,
                  value: '€45',
                  icon: Icons.card_giftcard,
                  color: Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Animations & Celebrations'),
            const SizedBox(height: 16),
            
            // Celebration Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CelebrationButton(
                  text: 'Objectif Atteint!',
                  icon: Icons.emoji_events,
                  onPressed: () {},
                  backgroundColor: Colors.amber,
                ),
                CelebrationButton(
                  text: 'Nouvelle Épargne',
                  icon: Icons.savings,
                  onPressed: () {},
                  backgroundColor: Colors.green,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Success Animation Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showSuccessDialog();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Afficher Animation Succès'),
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Loading Indicators'),
            const SizedBox(height: 16),
            
            // Loading Indicators Grid
            if (!_showLoading)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showLoading = true;
                  });
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _showLoading = false;
                      });
                    }
                  });
                },
                child: const Text('Afficher les indicateurs de chargement'),
              ),
            
            if (_showLoading) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const PulseLoadingIndicator(
                      color: Colors.blue,
                      message: 'Chargement des données...',
                    ),
                    const SizedBox(height: 32),
                    const DotsLoadingIndicator(
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 32),
                    const WaveLoadingIndicator(
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 32),
                    CircularProgressWithPercentage(
                      progress: _progressValue,
                      progressColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const ShimmerLoadingCard(),
              const SizedBox(height: 16),
              const ShimmerLoadingList(itemCount: 3),
            ],
            
            const SizedBox(height: 32),
            _buildSectionTitle('Animated Widgets'),
            const SizedBox(height: 16),
            
            // Animated Gradient Container
            AnimatedGradientContainer(
              gradients: const [
                [Color(0xFF667eea), Color(0xFF764ba2)],
                [Color(0xFFf093fb), Color(0xFFf5576c)],
                [Color(0xFF4facfe), Color(0xFF00f2fe)],
              ],
              child: const Center(
                child: Text(
                  'Gradient Animé',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              height: 120,
            ),
            
            const SizedBox(height: 16),
            
            // Pulsating Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                PulsatingIcon(
                  icon: Icons.favorite,
                  color: Colors.red,
                ),
                PulsatingIcon(
                  icon: Icons.star,
                  color: Colors.amber,
                ),
                PulsatingIcon(
                  icon: Icons.notifications,
                  color: Colors.blue,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Animated Counter
            Center(
              child: Column(
                children: [
                  AnimatedCounter(
                    value: _counterValue,
                    prefix: '€',
                    textStyle: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _counterValue += 250;
                      });
                    },
                    child: const Text('Augmenter le compteur'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Flip Card
            Center(
              child: SizedBox(
                width: 300,
                height: 180,
                child: FlipCard(
                  front: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card, size: 48, color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Carte de Crédit',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tapez pour retourner',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  back: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.red],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '**** **** **** 1234',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Solde: €2,450',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Animated Progress Bar
            AnimatedProgressBar(
              progress: _progressValue,
              height: 12,
              progressColor: Colors.green,
              borderRadius: BorderRadius.circular(6),
            ),
            
            const SizedBox(height: 16),
            
            // Typewriter Text
            const TypewriterText(
              text: 'Bienvenue dans FinanceAI Manager - Votre assistant financier intelligent!',
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSectionTitle('Animated List Items'),
            const SizedBox(height: 16),
            
            // Animated List Items
            ...List.generate(5, (index) {
              return AnimatedListItem(
                index: index,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.primaries[index % Colors.primaries.length]
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          [
                            Icons.shopping_cart,
                            Icons.restaurant,
                            Icons.directions_car,
                            Icons.home,
                            Icons.flight,
                          ][index],
                          color: Colors.primaries[index % Colors.primaries.length],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction ${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Description de la transaction',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '€${(index + 1) * 50}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: AnimatedFABMenu(
        backgroundColor: Colors.blue,
        children: [
          FloatingActionButton.small(
            heroTag: 'fab1',
            onPressed: () {},
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          FloatingActionButton.small(
            heroTag: 'fab2',
            onPressed: () {},
            backgroundColor: Colors.orange,
            child: const Icon(Icons.edit),
          ),
          FloatingActionButton.small(
            heroTag: 'fab3',
            onPressed: () {},
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: Colors.transparent,
        child: SuccessAnimation(
          message: 'Transaction Réussie!',
        ),
      ),
    );
    
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }
}
