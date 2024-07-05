import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommentWidget extends StatelessWidget {
  final snap;
  // final String comment;

  const CommentWidget({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 15.0,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('${snap['profilePic']}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        snap['name'],
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      snap['datePublished'] != null
                          ? DateFormat.yMMMd()
                              .format(snap['datePublished'].toDate())
                          : '',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  snap['text'],
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                    wordSpacing: 1.0,
                    height: 1.3,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
