const Note = require("../models/Note");

// @desc    Get kullanıcının tüm notlarını getir
// @route   GET /api/notes
// @access  Private
exports.getNotes = async (req, res) => {
  try {
    const notes = await Note.find({ user: req.user.id }).sort({
      createdAt: -1,
    });

    res.status(200).json({
      success: true,
      count: notes.length,
      data: notes,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Tekil not getir
// @route   GET /api/notes/:id
// @access  Private
exports.getNote = async (req, res) => {
  try {
    const note = await Note.findById(req.params.id);

    // Not bulunamadıysa
    if (!note) {
      return res.status(404).json({
        success: false,
        message: "Not bulunamadı",
      });
    }

    // Not başka bir kullanıcıya aitse
    if (note.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: "Bu nota erişim izniniz yok",
      });
    }

    res.status(200).json({
      success: true,
      data: note,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Not oluştur
// @route   POST /api/notes
// @access  Private
exports.createNote = async (req, res) => {
  try {
    const { title, content } = req.body;

    // Girdi doğrulama
    if (!title || !content) {
      return res.status(400).json({
        success: false,
        message: "Lütfen başlık ve içerik alanlarını doldurun",
      });
    }

    // Not oluştur
    const note = await Note.create({
      title,
      content,
      user: req.user.id,
    });

    res.status(201).json({
      success: true,
      data: note,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Not güncelle
// @route   PUT /api/notes/:id
// @access  Private
exports.updateNote = async (req, res) => {
  try {
    let note = await Note.findById(req.params.id);

    // Not bulunamadıysa
    if (!note) {
      return res.status(404).json({
        success: false,
        message: "Not bulunamadı",
      });
    }

    // Not başka bir kullanıcıya aitse
    if (note.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: "Bu notu düzenleme izniniz yok",
      });
    }

    // Notu güncelle
    note = await Note.findByIdAndUpdate(
      req.params.id,
      { $set: req.body },
      { new: true, runValidators: true }
    );

    res.status(200).json({
      success: true,
      data: note,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

// @desc    Not sil
// @route   DELETE /api/notes/:id
// @access  Private
exports.deleteNote = async (req, res) => {
  try {
    const note = await Note.findById(req.params.id);

    // Not bulunamadıysa
    if (!note) {
      return res.status(404).json({
        success: false,
        message: "Not bulunamadı",
      });
    }

    // Not başka bir kullanıcıya aitse
    if (note.user.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: "Bu notu silme izniniz yok",
      });
    }

    // Notu sil
    await note.deleteOne();

    res.status(200).json({
      success: true,
      data: {},
      message: "Not başarıyla silindi",
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};
