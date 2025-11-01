const mongoose = require("mongoose");

const articleSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  content: {
    type: String,
  },
  url: {
    type: String,
    required: true,
    unique: true,
  },
  urlToImage: {
    type: String,
  },
  publishedAt: {
    type: Date,
    required: true,
  },
  source: {
    name: String,
  },
  author: {
    type: String,
  },
  category: {
    type: String,
    enum: [
      "general",
      "business",
      "technology",
      "sports",
      "entertainment",
      "health",
      "science",
    ],
    default: "general",
  },
  summary: {
    type: String, // AI-generated summary
  },
  tags: [String], // For recommendations
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Index for efficient querying
articleSchema.index({ publishedAt: -1 });
articleSchema.index({ category: 1 });
articleSchema.index({ tags: 1 });

module.exports = mongoose.model("Article", articleSchema);
