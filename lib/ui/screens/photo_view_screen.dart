import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoViewScreen extends StatelessWidget {
    final String photoUrl;

  const PhotoViewScreen({Key? key, required this.photoUrl}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Scaffold(
                appBar: AppBar(
                title: Text('Beweisfoto'),
      ),
        body: Center(
                child: InteractiveViewer(
                panEnabled: true,
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4,
                child: CachedNetworkImage(
                imageUrl: photoUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
    }
}