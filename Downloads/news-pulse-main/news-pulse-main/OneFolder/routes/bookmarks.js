const express = require("express");
const Bookmark = require("../models/Bookmark");
const Article = require("../models/Article");
const Interaction = require("../models/Interaction");
const auth = require("../middleware/auth");

const router = express.Router();

// GET /api/bookmarks - Get user's bookmarks
router.get("/", auth, async (req, res) => {
  try {
    const userId = req.user._id;

    const bookmarks = await Bookmark.find({ user: userId })
      .populate("article")
      .sort({ createdAt: -1 });

    res.json({ bookmarks });
  } catch (error) {
    console.error("Error fetching bookmarks:", error);
    res.status(500).json({ message: "Failed to fetch bookmarks" });
  }
});

// POST /api/bookmarks - Add or remove bookmark
router.post("/", auth, async (req, res) => {
  try {
    const { action, articleData } = req.body;
    const userId = req.user._id;

    if (!["add", "remove"].includes(action)) {
      return res.status(400).json({ message: "Invalid action" });
    }

    // Find or create article
    let article = await Article.findOne({ url: articleData.url });
    if (!article) {
      if (!articleData.url) {
        return res.status(400).json({ message: "Article URL is required" });
      }
      article = new Article({
        title: articleData.title,
        description: articleData.description,
        content: articleData.content || articleData.description,
        url: articleData.url,
        urlToImage: articleData.urlToImage,
        publishedAt: new Date(articleData.publishedAt),
        source: articleData.source.name || articleData.source,
        author: articleData.author,
        category: articleData.category || "general",
      });
      await article.save();
    }

    if (action === "add") {
      // Check if already bookmarked
      const existingBookmark = await Bookmark.findOne({
        user: userId,
        article: article._id,
      });

      if (existingBookmark) {
        return res.json({ message: "Already bookmarked" });
      }

      // Create bookmark
      const bookmark = new Bookmark({
        user: userId,
        article: article._id,
      });
      await bookmark.save();

      // Record interaction
      const interaction = new Interaction({
        user: userId,
        article: article._id,
        type: "bookmark",
      });
      await interaction.save();

      console.log("Bookmark added successfully");
      res.json({ message: "Bookmark added", bookmark });
    } else if (action === "remove") {
      // Remove bookmark
      await Bookmark.findOneAndDelete({
        user: userId,
        article: article._id,
      });

      console.log("Bookmark removed successfully");
      res.json({ message: "Bookmark removed" });
    }
  } catch (error) {
    console.error("Error managing bookmark:", error);
    res.status(500).json({ message: "Failed to manage bookmark" });
  }
});

// GET /api/bookmarks/check/:articleId - Check if article is bookmarked
router.get("/check/:articleId", auth, async (req, res) => {
  try {
    const { articleId } = req.params;
    const userId = req.user._id;

    const bookmark = await Bookmark.findOne({
      user: userId,
      article: articleId,
    });

    res.json({ isBookmarked: !!bookmark });
  } catch (error) {
    console.error("Error checking bookmark:", error);
    res.status(500).json({ message: "Failed to check bookmark" });
  }
});

module.exports = router;
