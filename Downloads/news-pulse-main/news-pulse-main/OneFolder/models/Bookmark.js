const mongoose = require("mongoose");

const bookmarkSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  article: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Article",
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Ensure a user can't bookmark the same article twice
bookmarkSchema.index({ user: 1, article: 1 }, { unique: true });

module.exports = mongoose.model("Bookmark", bookmarkSchema);
