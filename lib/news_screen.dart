import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> news = [
    {
      'title': 'Breaking News 1',
      'image':
          'https://asset.kompas.com/crops/SffYT0pCH6dkB9TzSkK-cZPqU6o=/0x23:626x441/750x500/data/photo/2020/08/05/5f2a5a1a66dfa.jpg', // Placeholder image
      'date': '2024-10-10'
    },
    {
      'title': 'Breaking News 2',
      'image':
          'https://asset-a.grid.id/crop/0x0:0x0/x/photo/2021/09/23/teks-beritajpg-20210923101552.jpg',
      'date': '2024-10-11'
    },
    {
      'title': 'Breaking News 3',
      'image':
          'https://www.quipper.com/id/blog/wp-content/uploads/2022/12/Pengertian-Teks-Berita-Ciri-Struktur-Jenis-Unsur-dan-Contoh.webp',
      'date': '2024-10-12'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
      ),
      body: ListView.builder(
        itemCount: news.length,
        itemBuilder: (context, index) {
          return FadeInNewsCard(
            title: news[index]['title'],
            imageUrl: news[index]['image'],
            date: news[index]['date'],
            delay: (index + 1) * 200, // Different delay for each item
          );
        },
      ),
    );
  }
}

class FadeInNewsCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String date;
  final int delay;

  const FadeInNewsCard({
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.delay,
  });

  @override
  _FadeInNewsCardState createState() => _FadeInNewsCardState();
}

class _FadeInNewsCardState extends State<FadeInNewsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 12.0),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              widget.date,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
