const express = require("express");
const axios = require("axios");
const Article = require("../models/Article");
const Interaction = require("../models/Interaction");
const auth = require("../middleware/auth");

const router = express.Router();

// GET /api/news - Fetch news from NewsAPI and store in DB
router.get("/", async (req, res) => {
  try {
    const { category = "general", pageSize = 20 } = req.query;
    const newsApiKey = process.env.NEWS_API_KEY;

    if (!newsApiKey) {
      return res.status(400).json({ message: "NewsAPI key not configured" });
    }

    console.log(`Fetching news for category: ${category}`);

    const response = await axios.get("https://newsapi.org/v2/top-headlines", {
      params: {
        category,
        country: "us",
        pageSize,
        apiKey: newsApiKey,
      },
    });

    const { articles } = response.data;

    console.log(`NewsAPI response status: ${response.status}`);
    console.log(`Number of articles received: ${articles.length}`);
    console.log(`First article title: ${articles[0]?.title || "No articles"}`);
    console.log(`API Key present: ${!!newsApiKey}`);

    // Store articles in DB if they don't exist
    const savedArticles = [];
    for (const articleData of articles) {
      try {
        const article = new Article({
          title: articleData.title,
          description: articleData.description,
          content: articleData.content,
          url: articleData.url,
          urlToImage: articleData.urlToImage,
          publishedAt: new Date(articleData.publishedAt),
          source: articleData.source,
          author: articleData.author,
          category,
        });
        await article.save();
        savedArticles.push(article);
      } catch (error) {
        // Skip if article already exists (duplicate URL)
        if (error.code !== 11000) {
          console.error("Error saving article:", error);
        }
      }
    }

    console.log(
      `Successfully fetched and stored ${savedArticles.length} articles`
    );

    // Return articles from DB, not just the newly saved ones
    const dbArticles = await Article.find({ category })
      .sort({ publishedAt: -1 })
      .limit(parseInt(pageSize) || 20);

    res.json({ articles: dbArticles });
  } catch (error) {
    console.error("Error fetching news:", error.message);
    res.status(500).json({ message: "Failed to fetch news" });
  }
});

// POST /api/news/:articleId/view - Track article view (requires auth)
router.post("/:articleId/view", auth, async (req, res) => {
  try {
    const { articleId } = req.params;
    const userId = req.user._id;

    // Check if article exists
    const article = await Article.findById(articleId);
    if (!article) {
      return res.status(404).json({ message: "Article not found" });
    }

    // Record interaction
    const interaction = new Interaction({
      user: userId,
      article: articleId,
      type: "view",
    });
    await interaction.save();

    res.json({ message: "View recorded" });
  } catch (error) {
    console.error("Error recording view:", error);
    res.status(500).json({ message: "Failed to record view" });
  }
});

module.exports = router;
