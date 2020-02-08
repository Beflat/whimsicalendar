import 'package:flutter/cupertino.dart';
import 'package:whimsicalendar/widgets/calendar/event_collection.dart';

import 'calendar_event.dart';

/// カレンダーの状態を保持するオブジェクト
class CalendarController<T extends CalendarEvent> with ChangeNotifier {
  /// スワイプによるスクロールの方向
  int scrollDirection;

  /// 現在表示している月
  DateTime _currentMonth;

  /// 現在選択している日付。null = 未選択
  DateTime _selectedDate;

  /// カレンダーのイベント一覧
  EventCollection<T> _eventCollection;

  CalendarController({EventCollection<T> eventCollection})
      : _currentMonth = null,
        _selectedDate = null,
        _eventCollection = eventCollection {
    if (_currentMonth == null) {
      _currentMonth = DateTime.now();
    }
    if (_eventCollection == null) {
      _eventCollection = new EventCollection<T>();
    }
  }

  set currentMonth(DateTime date) {
    _currentMonth = date;
    notifyListeners();
  }

  set selectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  DateTime get currentMonth => _currentMonth;
  DateTime get selectedDate => _selectedDate;

  /// 次の月に変更する
  void goToNextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    scrollDirection = -1;
    notifyListeners();
  }

  /// 前の月に変更する
  void goToPrevMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    scrollDirection = 1;
    notifyListeners();
  }

  /// 指定した日にイベントを追加する
  void addEvent(DateTime date, T event) {
    _eventCollection.addEvent(date, event);
    notifyListeners();
  }

  /// 指定された日のイベントの一覧を返す
  List<T> getEventsOn(DateTime date) {
    return _eventCollection.getEventsOn(date);
  }

  /// 指定したキーが次の月を指しているかを返す
  bool isNextMonthKey(ValueKey key) {
    DateTime nextMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    return ValueKey(nextMonth) == key;
  }

  /// 指定したキーが前の月を指しているかを返す
  bool isPrevMonthKey(ValueKey key) {
    DateTime prevMonth =
        DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    return ValueKey(prevMonth) == key;
  }
}
