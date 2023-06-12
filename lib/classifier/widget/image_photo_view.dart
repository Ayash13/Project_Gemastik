import 'dart:io';
import 'package:flutter/material.dart';

class ImagePhotoView extends StatelessWidget {
  final File? file;
  const ImagePhotoView({Key? key, this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.5,
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(160, 255, 219, 153),
      ),
      alignment: AlignmentDirectional.center,
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
