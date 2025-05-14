import 'package:flutter/material.dart';
import 'package:novel_nest/models/review.dart';
import 'package:novel_nest/services/auth_service.dart';
import 'package:novel_nest/services/firestore_service.dart';
import 'package:provider/provider.dart';

class BookReviews extends StatefulWidget {
  final String bookId;
  final List<Review> reviews;
  final Future<void> Function() onSubmit;

  const BookReviews({
    super.key,
    required this.bookId,
    required this.reviews,
    required this.onSubmit,
  });

  @override
  State<BookReviews> createState() => _BookReviewsState();
}

class _BookReviewsState extends State<BookReviews> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final user = await authService.getCurrentUser();

    if ((_formKey.currentState?.validate() ?? false) && user != null) {
      setState(() => _isSubmitting = true);

      try {
        await firestoreService.addReview(
          bookId: widget.bookId,
          user: user,
          title: _titleController.text.trim(),
          content: _reviewController.text.trim(),
          rating: _rating,
        );
        await widget.onSubmit();

        _titleController.clear();
        _reviewController.clear();
        setState(() {
          _rating = 1;
          _isSubmitting = false;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting review'),
            ),
          );
        }
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blueGrey),
        color: const Color(0xFFF5F5F5),
        boxShadow: [
          const BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.blueGrey),
              color: Colors.white,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 10,
                children: [
                  const Text(
                    'Write a Review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rating:',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return IconButton(
                            icon: Icon(
                              Icons.star,
                              color: _rating >= starIndex
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = starIndex.toDouble();
                              });
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: 'Your Review',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 500,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your review';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      child: const Text('Submit'),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Divider(),
          if (widget.reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No reviews available'),
              ),
            ),
          ...widget.reviews.map((review) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.blueGrey),
                color: Colors.white,
              ),
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(review.title),
                        Text(
                          '${review.time.month}/${review.time.day}/${review.time.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      review.author,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text('${review.rating.toInt()} / 5'),
                      ],
                    ),
                  ],
                ),
                subtitle: Text(review.content),
              ),
            );
          }),
        ],
      ),
    );
  }
}
