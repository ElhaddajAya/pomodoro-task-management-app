import 'dart:async';
import 'package:audioplayers/audioplayers.dart'; // Importation de la bibliothèque pour jouer du son
import 'package:flutter/material.dart';

class PomodoroTimerPage extends StatefulWidget {
  const PomodoroTimerPage({super.key});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> with SingleTickerProviderStateMixin {
  // Définition des durées des sessions en secondes
  static const int workDuration = 25 * 60; // 25 minutes de travail
  static const int shortBreakDuration = 5 * 60; // 5 minutes de pause courte
  static const int longBreakDuration = 15 * 60; // 15 minutes de pause longue

  int remainingTime = workDuration; // Temps restant initial
  int pomodoroCount = 0; // Nombre de sessions terminées
  bool isWorkSession = true; // Indique si la session actuelle est une session de travail
  Timer? timer; // Timer pour gérer le compte à rebours
  bool isRunning = false; // Indique si le timer est en cours d'exécution
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isAlarmPlaying = false;

  // Fonction pour jouer un son lorsque le timer se termine
  void playSound() async {
    await _audioPlayer.play(AssetSource('alarm.mp3'));
    setState(() {
      isAlarmPlaying = true;
    });
  }

  // Arrêter l'alarme manuellement
  void _stopAlarm() async {
    await _audioPlayer.stop();
    setState(() {
      isAlarmPlaying = false;
    });
  }

  // Démarrer ou mettre en pause le timer
  void startPauseTimer() {
    if (isAlarmPlaying) {
      _stopAlarm(); // Stop the alarm when the timer is restarted
    }

    if (isRunning) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (remainingTime > 0) {
            remainingTime--;
          } else {
            timer.cancel();
            isRunning = false;
            playSound(); // Jouer le son de notification à la fin du timer
            _nextSession(); // Passer à la session suivante
          }
        });
      });
    }
    setState(() {
      isRunning = !isRunning;
    });
  }

  // Passer à la session suivante (travail -> pause -> travail...)
  void _nextSession() {
    setState(() {
      if (isWorkSession) {
        pomodoroCount++;
        // Après 4 sessions de travail, prendre une pause longue
        if (pomodoroCount % 4 == 0) {
          remainingTime = longBreakDuration;
          isWorkSession = false;
        } else {
          remainingTime = shortBreakDuration;
          isWorkSession = false;
        }
      } else {
        remainingTime = workDuration;
        isWorkSession = true;
      }
    });
  }

  // Réinitialiser le timer et les sessions
  void resetTimer() {
    timer?.cancel();
    _stopAlarm(); // Stop alarm when resetting
    setState(() {
      remainingTime = workDuration;
      isRunning = false;
      pomodoroCount = 0;
      isWorkSession = true;
    });
  }

  // Formater le temps en MM:SS
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Pomodoro Timer"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Affichage du type de session (travail, pause courte, pause longue)
            Text(
              isWorkSession ? "Work Session" : (pomodoroCount % 4 == 0 ? "Long Break" : "Short Break"),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Cercle de progression du temps
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: remainingTime / (isWorkSession ? workDuration : (pomodoroCount % 4 == 0 ? longBreakDuration : shortBreakDuration)),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey,
                    valueColor: const AlwaysStoppedAnimation(Colors.red),
                  ),
                ),
                // Affichage du temps restant
                Text(
                  formatTime(remainingTime),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Boutons de contrôle (Play/Pause et Reset)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startPauseTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.red,
                  ),
                  child: Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: resetTimer,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.white24,
                  ),
                  child: const Icon(
                    Icons.replay,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Stop alarm button (only visible when alarm is playing)
            if (isAlarmPlaying)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _stopAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Stop Alarm", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
