const express = require("express");
const OpenAI = require("openai");
const NodeCache = require("node-cache");
const Article = require("../models/Article");
const auth = require("../middleware/auth");

const router = express.Router();

// Check if OpenRouter API key is configured
if (!process.env.OPENROUTER_API_KEY) {
  console.error(
    "OpenRouter API key not configured. Please set OPENROUTER_API_KEY in your environment variables."
  );
}

// Initialize OpenRouter client (compatible with OpenAI SDK)
const openai = new OpenAI({
  baseURL: "https://openrouter.ai/api/v1",
  apiKey: process.env.OPENROUTER_API_KEY,
});

// Initialize cache (TTL: 24 hours)
const cache = new NodeCache({ stdTTL: 24 * 60 * 60 });

// POST /api/summarize - Summarize article using OpenAI
router.post("/", async (req, res) => {
  try {
    const { title, description, url, articleId } = req.body;

    if (!title || !description) {
      return res
        .status(400)
        .json({ message: "Title and description are required" });
    }

    // Check if article exists and has cached summary
    if (articleId) {
      const article = await Article.findById(articleId);
      if (article && article.summary) {
        return res.json({ summary: article.summary });
      }
    }

    // Create cache key
    const cacheKey = `summary_${Buffer.from(String(url || title || "default"))
      .toString("base64")
      .slice(0, 50)}`;

    // Check cache
    const cached = cache.get(cacheKey);
    if (cached) {
      return res.json({ summary: cached });
    }

    const prompt = `Please provide a concise 2-3 sentence summary of this news article:

Title: ${title}
Description: ${description}

Summary:`;

    // Check if API key is available before making the request
    if (!process.env.OPENROUTER_API_KEY) {
      return res
        .status(500)
        .json({ message: "OpenRouter API key not configured" });
    }

    const completion = await openai.chat.completions.create({
      model: "meta-llama/llama-3.2-3b-instruct:free",
      messages: [{ role: "user", content: prompt }],
      max_tokens: 150,
      temperature: 0.3,
    });

    const summary = completion.choices[0]?.message?.content?.trim();

    if (!summary) {
      return res.status(500).json({ message: "Failed to generate summary" });
    }

    // Cache the result
    cache.set(cacheKey, summary);

    // Update article with summary if articleId provided
    if (articleId) {
      await Article.findByIdAndUpdate(articleId, { summary });
    }

    res.json({ summary });
  } catch (error) {
    console.error("Error summarizing article:", error);
    res.status(500).json({ message: "Failed to summarize article" });
  }
});

module.exports = router;
