import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../budgets/providers/budget_provider.dart';
import '../goals/providers/goal_provider.dart';

class NotificationService {
  static const String budgetChannelId = 'budget_alerts';
  static const String goalChannelId = 'goal_alerts';
  static const String generalChannelId = 'general_notifications';

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createNotificationChannels();
  }

  static Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel budgetChannel = AndroidNotificationChannel(
      budgetChannelId,
      'Alertes Budget',
      description: 'Notifications pour les alertes de budget',
      importance: Importance.high,
    );

    const AndroidNotificationChannel goalChannel = AndroidNotificationChannel(
      goalChannelId,
      'Alertes Objectifs',
      description: 'Notifications pour les objectifs financiers',
      importance: Importance.defaultImportance,
    );

    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      generalChannelId,
      'Notifications Générales',
      description: 'Notifications générales de l\'application',
      importance: Importance.defaultImportance,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(budgetChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(goalChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Gérer les actions lors du tap sur une notification
    debugPrint('Notification tapped: ${response.payload}');
  }

  static Future<void> showBudgetAlert({
    required String budgetName,
    required double percentage,
    required bool isExceeded,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      budgetChannelId,
      'Alertes Budget',
      channelDescription: 'Notifications pour les alertes de budget',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final String title = isExceeded 
        ? '⚠️ Budget dépassé !'
        : '📊 Alerte budget';
    
    final String body = isExceeded
        ? 'Votre budget "$budgetName" a été dépassé (${percentage.toStringAsFixed(1)}%)'
        : 'Attention ! Vous avez utilisé ${percentage.toStringAsFixed(1)}% de votre budget "$budgetName"';

    await flutterLocalNotificationsPlugin.show(
      budgetName.hashCode,
      title,
      body,
      notificationDetails,
      payload: 'budget:$budgetName',
    );
  }

  static Future<void> showGoalAchieved({
    required String goalName,
    required double amount,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      goalChannelId,
      'Alertes Objectifs',
      channelDescription: 'Notifications pour les objectifs financiers',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      goalName.hashCode,
      '🎉 Objectif atteint !',
      'Félicitations ! Vous avez atteint votre objectif "$goalName" de ${amount.toStringAsFixed(0)} CFA',
      notificationDetails,
      payload: 'goal:$goalName',
    );
  }

  static Future<void> showGoalDeadlineReminder({
    required String goalName,
    required int daysLeft,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      goalChannelId,
      'Alertes Objectifs',
      channelDescription: 'Notifications pour les objectifs financiers',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      'deadline_${goalName.hashCode}'.hashCode,
      '⏰ Échéance proche',
      'Il vous reste $daysLeft jours pour atteindre votre objectif "$goalName"',
      notificationDetails,
      payload: 'goal_deadline:$goalName',
    );
  }

  static Future<void> showGeneralNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      generalChannelId,
      'Notifications Générales',
      channelDescription: 'Notifications générales de l\'application',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static Future<void> checkAndSendBudgetAlerts(BudgetProvider budgetProvider) async {
    final budgetsToAlert = budgetProvider.budgetsProchesLimite;
    final budgetsExceeded = budgetProvider.budgetsDepasses;

    // Alertes pour budgets proches de la limite
    for (final budget in budgetsToAlert) {
      await showBudgetAlert(
        budgetName: budget.nom,
        percentage: budget.pourcentageUtilise * 100,
        isExceeded: false,
      );
    }

    // Alertes pour budgets dépassés
    for (final budget in budgetsExceeded) {
      await showBudgetAlert(
        budgetName: budget.nom,
        percentage: budget.pourcentageUtilise * 100,
        isExceeded: true,
      );
    }
  }

  static Future<void> checkAndSendGoalAlerts(GoalProvider goalProvider) async {
    final goals = goalProvider.goals;

    for (final goal in goals) {
      // Vérifier si l'objectif vient d'être atteint
      if (goal.estAtteint && goal.estComplete) {
        await showGoalAchieved(
          goalName: goal.nom,
          amount: goal.montantCible,
        );
      }

      // Vérifier les échéances proches
      if (goal.joursRestants != null && 
          goal.joursRestants! <= 7 && 
          goal.joursRestants! > 0 &&
          !goal.estAtteint) {
        await showGoalDeadlineReminder(
          goalName: goal.nom,
          daysLeft: goal.joursRestants!,
        );
      }
    }
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
