const mongoose = require("mongoose");

const interactionSchema = new mongoose.Schema({
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
  type: {
    type: String,
    enum: ["view", "bookmark", "like"],
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

// Index for efficient recommendation queries
interactionSchema.index({ user: 1, timestamp: -1 });
interactionSchema.index({ article: 1, type: 1 });

module.exports = mongoose.model("Interaction", interactionSchema);
