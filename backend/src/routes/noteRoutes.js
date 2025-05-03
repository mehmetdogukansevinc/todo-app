const express = require("express");
const {
  getNotes,
  getNote,
  createNote,
  updateNote,
  deleteNote,
} = require("../controllers/noteController");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

// Tüm rotalar auth middleware ile korunuyor
router.use(protect);

// /api/notes
router.route("/").get(getNotes).post(createNote);

// /api/notes/:id
router.route("/:id").get(getNote).put(updateNote).delete(deleteNote);

module.exports = router;
