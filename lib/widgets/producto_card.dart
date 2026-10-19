import 'package:flutter/material.dart';

import '../models/models.dart';

class ProductoCard extends StatelessWidget {
  final Product producto;
  final VoidCallback onTap;

  const ProductoCard({super.key, required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black12,
                child: ImagenRed(url: producto.imagenPrincipal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    producto.brand.isEmpty ? producto.category : producto.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${producto.price.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                          Text(producto.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagenRed extends StatelessWidget {
  final String url;
  final BoxFit ajuste;

  const ImagenRed({super.key, required this.url, this.ajuste = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.black38));
    }
    return Image.network(
      url,
      fit: ajuste,
      loadingBuilder: (context, child, progreso) {
        if (progreso == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black));
      },
      errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.black38)),
    );
  }
}
