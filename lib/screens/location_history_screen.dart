import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LocationHistory extends StatefulWidget {
  const LocationHistory({Key? key}) : super(key: key);

  @override
  State<LocationHistory> createState() => _LocationHistoryState();
}

class _LocationHistoryState extends State<LocationHistory> {
 final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true,title: const Text("Accidents History"),),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: db
                  .collection('locations')
                  // .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                final messages = snapshot.data?.docs;
                List<MessageBubble> messageBubbles = [];

                for (var message in messages!) {
                  final accidentLocation = message.get('text');
                   // final time = message.get('timestamp');
                   //
                   // final currentTime = Timestamp.fromMicrosecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);
                   // final timeStamps = time == null ? currentTime : time as Timestamp;


                  final messageBubble = MessageBubble(
                    location: accidentLocation,
                    documentReference: message.reference,
                     // timestamp: timeStamps,
                  );

                  messageBubbles.add(messageBubble);
                }
                return Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    children: messageBubbles,
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}


class MessageBubble extends StatelessWidget {
    const MessageBubble(
      {Key? key,
        required this.location,
  required this.documentReference,
         //required this.timestamp,
      })
      : super(key: key);

  final String location;
  final documentReference;
   //final Timestamp timestamp;
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.black54,
                  ),
                  const SizedBox(
                    height: 40,
                    child: VerticalDivider(
                      thickness: 1,
                      color: Colors.black12,
                      width: 40,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Accident Location",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          location,
                          style: const TextStyle(color: Colors.black38),
                        ),
                        // Text(
                          //   DateFormat('hh:mm').format(timestamp.toDate()), // Display timestamp
                          //   style: const TextStyle(
                          //     color: Colors.grey,
                          //     fontSize: 12.0,
                          //   ),

                        // )
                      ],
                    ),
                  ),
                // const Spacer(),
                  IconButton(
                    onPressed: (){
                      documentReference.delete();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                          Text('Location Deleted')));
                    },
                      icon: const Icon(
                      Icons.delete,
                      size: 30,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
