import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/movie_model.dart';

enum PosterSource { device, url }

class AddEditMovieDialog extends StatefulWidget {
  final Movie? movie;
  final String createdBy;

  const AddEditMovieDialog({
    super.key,
    this.movie,
    required this.createdBy,
  });

  @override
  State<AddEditMovieDialog> createState() => _AddEditMovieDialogState();
}

class _AddEditMovieDialogState extends State<AddEditMovieDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _yearController = TextEditingController();
  final _ratingController = TextEditingController();

  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Animation', 'Comedy', 'Crime',
    'Documentary', 'Drama', 'Fantasy', 'Horror', 'Mystery',
    'Romance', 'Sci-Fi', 'Thriller', 'Western',
  ];

  List<String> _selectedGenres = [];
  XFile? _posterFile; 
  PosterSource _posterSource = PosterSource.device;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _titleController.text = widget.movie!.title;
      _descriptionController.text = widget.movie!.description ?? '';
      _posterUrlController.text = widget.movie!.posterUrl ?? '';
      _yearController.text = widget.movie!.year ?? '';
      _ratingController.text = widget.movie!.rating?.toString() ?? '';
      _selectedGenres = List.from(widget.movie!.genres);

      if (_posterUrlController.text.isNotEmpty) {
        _posterSource = PosterSource.url;
      } 
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _posterUrlController.dispose();
    _yearController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (_selectedGenres.contains(genre)) {
        _selectedGenres.remove(genre);
      } else {
        _selectedGenres.add(genre);
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final movie = Movie(
        id: widget.movie?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        posterUrl: _posterSource == PosterSource.device
            ? (_posterFile?.path ?? '')
            : _posterUrlController.text.trim(),
        year: _yearController.text.trim(),
        genres: _selectedGenres,
        rating: _ratingController.text.isNotEmpty
            ? double.tryParse(_ratingController.text.trim())
            : null,
        createdAt: widget.movie?.createdAt ?? DateTime.now(),
        createdBy: widget.movie?.createdBy ?? widget.createdBy,
      );

      Navigator.of(context).pop(movie);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.movie != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.filmStrip(), color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Movie' : 'Add New Movie',
                      style: AppTheme.titleStyle.copyWith(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Title *',
                          prefixIcon: Icon(PhosphorIcons.textT()),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(PhosphorIcons.notepad()),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                     // Poster source radio buttons (horizontal)
Text('Poster Source', style: AppTheme.subtitleStyle),
const SizedBox(height: 8),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    // Premier bouton radio
    SizedBox(
      width: 200, // Largeur fixe pour éviter le chevauchement
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<PosterSource>(
            value: PosterSource.device,
            groupValue: _posterSource,
            onChanged: (value) {
              setState(() {
                _posterSource = value!;
                _posterUrlController.clear();
              });
            },
          ),
          Expanded(
            child: Text(
              'Upload from device',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
    
    // Deuxième bouton radio
    SizedBox(
      width: 150, // Largeur fixe pour éviter le chevauchement
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<PosterSource>(
            value: PosterSource.url,
            groupValue: _posterSource,
            onChanged: (value) {
              setState(() {
                _posterSource = value!;
                _posterFile = null;
              });
            },
          ),
          Expanded(
            child: Text(
              'Enter URL',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  ],
),
const SizedBox(height: 12),
                      // Conditional: select file or enter URL
                      if (_posterSource == PosterSource.device)
                        ElevatedButton.icon(
                          icon: Icon(PhosphorIcons.folderSimplePlus()),
                          label: const Text('Select Poster'),
                          onPressed: () async {
                            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                _posterFile = pickedFile;
                              });
                            }
                          },
                        )
                      else
                        TextFormField(
                          controller: _posterUrlController,
                          decoration: InputDecoration(
                            labelText: 'Poster URL',
                            prefixIcon: Icon(PhosphorIcons.image()),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value.isNotEmpty) _posterFile = null;
                            });
                          },
                        ),
                      const SizedBox(height: 16),

                      // Poster preview
                      Center(
                        child: Container(
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppTheme.textLight.withOpacity(0.1),
                            border: Border.all(color: AppTheme.textLight.withOpacity(0.3)),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: _posterFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(_posterFile!.path), fit: BoxFit.cover),
                                )
                              : (_posterUrlController.text.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _posterUrlController.text,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          PhosphorIcons.filmStrip(),
                                          size: 40,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      PhosphorIcons.filmStrip(),
                                      size: 40,
                                      color: AppTheme.textLight,
                                    )),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Year & Rating
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _yearController,
                              decoration: InputDecoration(
                                labelText: 'Year',
                                prefixIcon: Icon(PhosphorIcons.calendar()),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _ratingController,
                              decoration: InputDecoration(
                                labelText: 'Rating',
                                prefixIcon: Icon(PhosphorIcons.star()),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Genres
                      Text('Genres', style: AppTheme.subtitleStyle),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableGenres.map((genre) {
                          final isSelected = _selectedGenres.contains(genre);
                          return ChoiceChip(
                            label: Text(genre),
                            selected: isSelected,
                            onSelected: (_) => _toggleGenre(genre),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(isEditing ? PhosphorIcons.pencilSimple() : PhosphorIcons.plus()),
                          label: Text(isEditing ? 'Update Movie' : 'Add Movie'),
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
