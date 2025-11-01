const express = require("express");
const Bookmark = require("../models/Bookmark");
const Article = require("../models/Article");
const Interaction = require("../models/Interaction");
const auth = require("../middleware/auth");

const router = express.Router();

// GET /api/recommendations - Get personalized recommendations
router.get("/", auth, async (req, res) => {
  try {
    const userId = req.user._id;

    // Get user's bookmarks to understand preferences
    const bookmarks = await Bookmark.find({ user: userId })
      .populate("article")
      .sort({ createdAt: -1 })
      .limit(20);

    if (bookmarks.length === 0) {
      // If no bookmarks, return recent general articles
      const recentArticles = await Article.find()
        .sort({ publishedAt: -1 })
        .limit(6);

      return res.json({
        recommendations: recentArticles.map((article) => ({
          ...article.toObject(),
          isRecommended: true,
        })),
      });
    }

    // Analyze user preferences based on bookmarks
    const sourcePreferences = {};
    const categoryPreferences = {};
    const tagPreferences = {};

    bookmarks.forEach((bookmark) => {
      const article = bookmark.article;

      // Count source preferences
      const source = article.source?.name || "unknown";
      sourcePreferences[source] = (sourcePreferences[source] || 0) + 1;

      // Count category preferences
      const category = article.category || "general";
      categoryPreferences[category] = (categoryPreferences[category] || 0) + 1;

      // Count tag preferences (if available)
      if (article.tags) {
        article.tags.forEach((tag) => {
          tagPreferences[tag] = (tagPreferences[tag] || 0) + 1;
        });
      }
    });

    // Get top preferences
    const topSources = Object.entries(sourcePreferences)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 3)
      .map(([source]) => source);

    const topCategories = Object.entries(categoryPreferences)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 2)
      .map(([category]) => category);

    // Find recommended articles based on preferences
    const recommendations = await Article.find({
      $or: [
        { "source.name": { $in: topSources } },
        { category: { $in: topCategories } },
      ],
      _id: { $nin: bookmarks.map((b) => b.article._id) }, // Exclude already bookmarked
    })
      .sort({ publishedAt: -1 })
      .limit(12);

    // If not enough recommendations, fill with recent articles
    if (recommendations.length < 6) {
      const additionalArticles = await Article.find({
        _id: {
          $nin: [
            ...recommendations.map((a) => a._id),
            ...bookmarks.map((b) => b.article._id),
          ],
        },
      })
        .sort({ publishedAt: -1 })
        .limit(6 - recommendations.length);

      recommendations.push(...additionalArticles);
    }

    res.json({
      recommendations: recommendations.slice(0, 6).map((article) => ({
        ...article.toObject(),
        isRecommended: true,
      })),
    });
  } catch (error) {
    console.error("Error getting recommendations:", error);
    res.status(500).json({ message: "Failed to get recommendations" });
  }
});

module.exports = router;
