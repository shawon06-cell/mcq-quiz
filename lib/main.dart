import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MCQQuizApp());

class Question {
  final String q;
  final List<String> options;
  final int answer;
  const Question(this.q, this.options, this.answer);
}

const questions = [
  Question('বাংলাদেশের রাজধানী কোনটি?', ['চট্টগ্রাম', 'ঢাকা', 'সিলেট', 'রাজশাহী'], 1),
  Question('বাংলা বর্ণমালায় স্বরবর্ণ কতটি?', ['৯টি', '১০টি', '১১টি', '১২টি'], 2),
  Question('৫ × ৬ = কত?', ['২৫', '৩০', '৩৫', '৪০'], 1),
  Question('পদ্মা সেতু কোন নদীর ওপর নির্মিত?', ['যমুনা', 'মেঘনা', 'পদ্মা', 'কর্ণফুলী'], 2),
  Question('জাতীয় কবি কে?', ['রবীন্দ্রনাথ ঠাকুর', 'কাজী নজরুল ইসলাম', 'জসীমউদ্দীন', 'সুকান্ত ভট্টাচার্য'], 1),
  Question('পৃথিবীর উপগ্রহ কোনটি?', ['সূর্য', 'মঙ্গল', 'চাঁদ', 'শুক্র'], 2),
  Question('১ কিলোমিটারে কত মিটার?', ['১০', '১০০', '১০০০', '১০,০০০'], 2),
  Question('বাংলাদেশের জাতীয় ফুল কোনটি?', ['গোলাপ', 'শাপলা', 'জবা', 'বেলি'], 1),
  Question('সূর্য কোন দিক থেকে উদিত হয়?', ['পশ্চিম', 'উত্তর', 'দক্ষিণ', 'পূর্ব'], 3),
  Question('স্বাধীন বাংলাদেশের প্রথম রাষ্ট্রপতি কে ছিলেন?', ['শেখ মুজিবুর রহমান', 'জিয়াউর রহমান', 'সৈয়দ নজরুল ইসলাম', 'আবু সাঈদ চৌধুরী'], 0),
];

class MCQQuizApp extends StatelessWidget {
  const MCQQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MCQ Quiz',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        fontFamily: 'sans',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int best = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => best = p.getInt('best') ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xffeef2ff),
              Color(0xffdbeafe),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Colors.white,
                      size: 58,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'MCQ Quiz',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'নিজেকে যাচাই করুন, জ্ঞান বাড়ান!',
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 34),
                  Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            color: Colors.amber,
                            size: 30,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'সেরা স্কোর: $best/10',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuizPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        'Quiz শুরু করুন',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int index = 0;
  int score = 0;
  int selected = -1;
  int seconds = 30;

  Timer? timer;
  bool locked = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        if (seconds <= 1) {
          _next();
        } else {
          setState(() => seconds--);
        }
      },
    );
  }

  void _choose(int i) {
    if (locked) return;

    setState(() {
      selected = i;
      locked = true;

      if (i == questions[index].answer) {
        score++;
      }
    });

    Future.delayed(
      const Duration(milliseconds: 700),
      () {
        if (mounted) _next();
      },
    );
  }

  void _next() {
    if (!mounted) return;

    if (index == questions.length - 1) {
      timer?.cancel();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(score: score),
        ),
      );
    } else {
      setState(() {
        index++;
        selected = -1;
        locked = false;
        seconds = 30;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCQ Quiz'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'প্রশ্ন ${index + 1}/${questions.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: seconds <= 5
                        ? Colors.red.shade50
                        : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⏱ $seconds সেকেন্ড',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: seconds <= 5
                          ? Colors.red
                          : Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (index + 1) / questions.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 28),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  q.q,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ...List.generate(
              q.options.length,
              (i) {
                final correct = i == q.answer;
                final picked = i == selected;

                Color? bg;

                if (locked && correct) {
                  bg = Colors.green.shade100;
                }

                if (locked && picked && !correct) {
                  bg = Colors.red.shade100;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _choose(i),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: bg ?? Colors.white,
                        border: Border.all(
                          color: locked && (correct || picked)
                              ? (correct ? Colors.green : Colors.red)
                              : Colors.grey.shade300,
                          width: 1.4,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            child: Text(
                              String.fromCharCode(65 + i),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (locked && correct)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          if (locked && picked && !correct)
                            const Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            Text(
              'সঠিক উত্তর নির্বাচন করুন',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;

  const ResultPage({
    super.key,
    required this.score,
  });

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    final old = p.getInt('best') ?? 0;

    if (score > old) {
      await p.setInt('best', score);
    }
  }

  @override
  Widget build(BuildContext context) {
    _save();

    final pct = (score / questions.length * 100).round();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 90,
                color: Colors.amber,
              ),
              const SizedBox(height: 18),
              const Text(
                'Quiz শেষ!',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                '$score / ${questions.length}',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '$pct% সঠিক',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 30),
              Text(
                score >= 8
                    ? 'দারুণ! 🎉'
                    : score >= 5
                        ? 'ভালো হয়েছে! 👍'
                        : 'আরও চেষ্টা করুন! 💪',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 34),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuizPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'আবার Quiz দিন',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('হোমে ফিরে যান'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
