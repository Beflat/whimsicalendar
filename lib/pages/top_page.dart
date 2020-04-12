import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:whimsicalendar/auth/authenticator_interface.dart';
import 'package:whimsicalendar/domain/calendar/calendar_event_repository_interface.dart';
import 'package:whimsicalendar/domain/user/user.dart';
import 'package:whimsicalendar/infrastructure/repositories/calendar_event/calendar_repository.dart';
import 'package:whimsicalendar/infrastructure/url_sharing/url_sharing_handler.dart';
import 'package:whimsicalendar/widgets/calendar/calendar.dart';

import 'calendar/calendar_view_model.dart';
import 'event/register_form.dart';

/// トップページ
class TopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<CalendarEventRepositoryInterface>(
              create: (BuildContext context) => CalendarEventRepository()),
          Provider<CalendarViewModel>(
              create: (BuildContext context) => CalendarViewModel(context)),
        ],
        child: Builder(builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(title: Text('Whisimicalendar')),
              body: Column(children: [CalendarSection()]),
              floatingActionButton: Builder(builder: (BuildContext context) {
                return FloatingActionButton(
                    onPressed: () => _onFloatingActionButtonPressed(context),
                    child: Icon(Icons.add));
              }));
        }));
  }

  /// FABを押下した時の動作
  void _onFloatingActionButtonPressed(BuildContext context) async {
    final registered = await Navigator.of(context).pushNamed('/event/add',
        arguments: EventRegisterPageArguments(
            currentDate: Provider.of<CalendarViewModel>(context, listen: false)
                .currentDate));

    if (registered == true) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('登録しました。')));
    }
  }
}

class CalendarSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CalendarSectionState();
}

class CalendarSectionState extends State<CalendarSection> {
  User _user;
  StreamSubscription _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();

    _user = null;
    WidgetsBinding.instance.addPostFrameCallback((Duration d) async {
      var authenticator =
          Provider.of<AuthenticatorInterface>(context, listen: false);
      if (!await authenticator.isAuthenticated()) {
        Navigator.of(context).pushReplacementNamed('/sign-in');
        return;
      }

      _user = await authenticator.getUser();

      //アプリケーションの起動中にURLのインテントを受け取った場合
      Provider.of<UrlSharingHandler>(context, listen: false)
          .subscribe((String sharedUrl) async {
        await Navigator.of(context).pushNamed('/event/add',
            arguments: EventRegisterPageArguments(url: sharedUrl));
      });

      //URLのインテントを受け取って起動した場合
      ReceiveSharingIntent.getInitialText().then((String text) async {
        if (text == null) {
          return;
        }
        await Navigator.of(context).pushNamed('/event/add',
            arguments: EventRegisterPageArguments(url: text));
      });
    });
  }

  @override
  void didUpdateWidget(CalendarSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    CalendarViewModel viewModel = Provider.of<CalendarViewModel>(context);
    if (viewModel.shouldUpdateEventList()) {
      viewModel.loadEventList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: CalendarView(
            controller: Provider.of<CalendarViewModel>(context, listen: false)
                .calendarController));
  }

  @override
  dispose() {
    _intentDataStreamSubscription.cancel();
  }
}
