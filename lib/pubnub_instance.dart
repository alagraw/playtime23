import 'package:pubnub/pubnub.dart';
import 'keys.dart';

class PubNubInstance {
  late PubNub _pubnub;
  late Subscription _subscription;

  PubNub get instance => _pubnub;

  Subscription get subscription => _subscription;

  PubNubInstance() {
    //  Create PubNub configuration and instantiate the PubNub object, used to communicate with PubNub
    _pubnub = PubNub(
        defaultKeyset: Keyset(
            subscribeKey: Keys.pubnubSubscribeKey,
            publishKey: Keys.pubnubPublishKey,
            ));

    _subscription =
        _pubnub.subscribe(channels: {"playtime"}, withPresence: true);
  }

  dispose() async {}
}
