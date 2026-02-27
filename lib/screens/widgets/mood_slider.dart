import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class MoodSlider extends StatefulWidget {
  final String currentMood;
  final Function(String) onMoodChanged;

  const MoodSlider({
    Key? key,
    required this.currentMood,
    required this.onMoodChanged,
  }) : super(key: key);

  @override
  _MoodSliderState createState() => _MoodSliderState();
}

class _MoodSliderState extends State<MoodSlider> {
  final List<String> _moods = ['Sad', 'Neutral', 'Happy'];
  final List<IconData> _moodIcons = [
    Icons.sentiment_very_dissatisfied,
    Icons.sentiment_neutral,
    Icons.sentiment_very_satisfied,
  ];
  final List<Color> _moodColors = [Colors.red, Colors.amber, Colors.green];

  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = _moods.indexOf(widget.currentMood).toDouble();
    if (_currentSliderValue == -1) _currentSliderValue = 1; // Default to Neutral
  }

  @override
  Widget build(BuildContext context) {
    int moodIndex = _currentSliderValue.round();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'How are you feeling today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Icon(
              _moodIcons[moodIndex],
              size: 80,
              color: _moodColors[moodIndex],
            ),
            const SizedBox(height: 10),
            Text(
              _moods[moodIndex],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _moodColors[moodIndex],
              ),
            ),
            const SizedBox(height: 10),
            Slider(
              value: _currentSliderValue,
              min: 0,
              max: 2,
              divisions: 2,
              activeColor: _moodColors[moodIndex],
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
              onChangeEnd: (double value) {
                widget.onMoodChanged(_moods[value.round()]);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Sad'),
                Text('Neutral'),
                Text('Happy'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
