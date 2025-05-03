const express = require("express");
const {
  register,
  login,
  getCurrentUser,
  logout,
} = require("../controllers/authController");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

// Register a new user
router.post("/register", register);

// Login user
router.post("/login", login);

// Get current user profile
router.get("/me", protect, getCurrentUser);

// Logout user
router.post("/logout", protect, logout);

module.exports = router;
