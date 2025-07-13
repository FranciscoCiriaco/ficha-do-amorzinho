import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatDateForStorage(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTimeForStorage(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static DateTime? parseDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy').parse(dateString);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd').parse(dateString);
      } catch (e) {
        return null;
      }
    }
  }

  static DateTime? parseTime(String timeString) {
    try {
      return DateFormat('HH:mm').parse(timeString);
    } catch (e) {
      return null;
    }
  }

  static String getWeekDay(DateTime date) {
    final List<String> weekDays = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
    ];
    return weekDays[date.weekday % 7];
  }

  static String getMonth(DateTime date) {
    final List<String> months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[date.month - 1];
  }

  static String getMonthYear(DateTime date) {
    return '${getMonth(date)} ${date.year}';
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isTomorrow(DateTime date) {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  static bool isYesterday(DateTime date) {
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static String getRelativeDate(DateTime date) {
    if (isToday(date)) {
      return 'Hoje';
    } else if (isTomorrow(date)) {
      return 'Amanhã';
    } else if (isYesterday(date)) {
      return 'Ontem';
    } else {
      return formatDate(date);
    }
  }

  static String getAge(DateTime birthDate) {
    final DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age.toString();
  }

  static List<DateTime> getWeekDates(DateTime date) {
    final int weekDay = date.weekday;
    final DateTime monday = date.subtract(Duration(days: weekDay - 1));
    
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  static List<DateTime> getMonthDates(DateTime date) {
    final DateTime firstDay = DateTime(date.year, date.month, 1);
    final DateTime lastDay = DateTime(date.year, date.month + 1, 0);
    
    List<DateTime> dates = [];
    for (int i = 0; i < lastDay.day; i++) {
      dates.add(firstDay.add(Duration(days: i)));
    }
    
    return dates;
  }

  static int getDaysDifference(DateTime date1, DateTime date2) {
    return date1.difference(date2).inDays;
  }

  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  static DateTime getNextWorkingDay(DateTime date) {
    DateTime nextDay = date.add(const Duration(days: 1));
    while (isWeekend(nextDay)) {
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return nextDay;
  }

  static DateTime getPreviousWorkingDay(DateTime date) {
    DateTime prevDay = date.subtract(const Duration(days: 1));
    while (isWeekend(prevDay)) {
      prevDay = prevDay.subtract(const Duration(days: 1));
    }
    return prevDay;
  }
}