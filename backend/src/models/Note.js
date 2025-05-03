const mongoose = require("mongoose");

const noteSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, "Not başlığı gereklidir"],
      trim: true,
    },
    content: {
      type: String,
      required: [true, "Not içeriği gereklidir"],
      trim: true,
    },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    completed: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

// Notları kullanıcıya göre indeksleme
noteSchema.index({ user: 1 });

const Note = mongoose.model("Note", noteSchema);

module.exports = Note;
