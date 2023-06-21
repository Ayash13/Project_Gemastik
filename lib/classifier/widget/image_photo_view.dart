import 'dart:io';
import 'package:flutter/material.dart';

class ImagePhotoView extends StatelessWidget {
  final File? file;
  const ImagePhotoView({Key? key, this.file});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.42,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        elevation: 0,
        color: const Color.fromARGB(160, 255, 219, 153),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: (file == null)
            ? _buildEmptyView()
            : ClipRect(
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.file(
                      file!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Icon(
        Icons.image,
        size: 100,
      ),
    );
  }
}
