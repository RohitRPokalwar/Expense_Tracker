import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { TrendingUp, Loader2 } from "lucide-react";
import { motion } from "framer-motion";
import NewsCard from "@/components/NewsCard";
import CategoryFilter from "@/components/CategoryFilter";
import Analytics from "@/components/Analytics";
import BookmarksPanel from "@/components/BookmarksPanel";
import Navbar from "@/components/Navbar";
import { useToast } from "@/hooks/use-toast";
import { useAuth } from "@/hooks/useAuthNew";
import apiClient from "@/integrations/api/client";

export interface Article {
  title: string;
  description: string;
  url: string;
  urlToImage: string;
  source: { name: string };
  publishedAt: string;
  author?: string;
  isRecommended?: boolean;
}

const LS_KEY = "bookmarks_v1";

const Index = () => {
  const [articles, setArticles] = useState<Article[]>([]);
  const [loading, setLoading] = useState(false);
  const [category, setCategory] = useState("general");
  const [showAnalytics, setShowAnalytics] = useState(false);
  const [showBookmarks, setShowBookmarks] = useState(false);
  const [bookmarks, setBookmarks] = useState<Article[]>([]);

  const { toast } = useToast();
  const { user, loading: authLoading, signOut } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    // Redirect to auth if not logged in
    if (!authLoading && !user) {
      navigate("/auth");
    }
  }, [user, authLoading, navigate]);

  useEffect(() => {
    if (user) {
      loadBookmarks();
    }
  }, [user]);

  useEffect(() => {
    if (user) {
      fetchNews();
    }
  }, [category, user]);

  const fetchNews = async () => {
    setLoading(true);
    try {
      const response = await apiClient.get('/news', {
        params: { category }
      });

      if (response.data.articles) {
        setArticles(response.data.articles.filter((a: Article) => a.title && a.description));
      }
    } catch (error) {
      console.error('Error fetching news:', error);
      toast({
        title: "Error fetching news",
        description: "Please try again later",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const loadBookmarks = async () => {
    if (!user) return;

    try {
      const response = await apiClient.get('/bookmarks');
      const bookmarkArticles = response.data.bookmarks.map((b: any) => ({
        title: b.article.title,
        description: b.article.description,
        url: b.article.url,
        urlToImage: b.article.urlToImage,
        source: { name: b.article.source.name || b.article.source },
        publishedAt: b.article.publishedAt instanceof Date ? b.article.publishedAt.toISOString() : b.article.publishedAt,
        author: b.article.author,
      }));
      setBookmarks(bookmarkArticles);
      try {
        localStorage.setItem(LS_KEY, JSON.stringify(bookmarkArticles));
      } catch {
        // Ignore localStorage errors
      }
    } catch (error) {
      console.error('Error loading bookmarks:', error);
      // Fallback to localStorage cache
      try {
        const cached = localStorage.getItem(LS_KEY);
        if (cached) setBookmarks(JSON.parse(cached));
      } catch {
        // Ignore localStorage errors
      }
      toast({
        title: "Using offline bookmarks",
        description: "Server sync failed. Showing cached bookmarks.",
        variant: "default",
      });
    }
  };



  const toggleBookmark = async (article: Article) => {
    if (!user) {
      toast({
        title: "Please sign in",
        description: "You need to be signed in to bookmark articles",
        variant: "destructive",
      });
      return;
    }

    const isBookmarked = bookmarks.some((b) => b.url === article.url);

    try {
      await apiClient.post('/bookmarks', {
        action: isBookmarked ? 'remove' : 'add',
        articleData: article
      });

      if (isBookmarked) {
        toast({ title: "Removed from bookmarks", variant: "default" });
      } else {
        toast({ title: "Added to bookmarks", variant: "default" });
      }

      // Reload bookmarks to sync with server
      loadBookmarks();
    } catch (error) {
      console.error('Error managing bookmark:', error);
      toast({
        title: "Error",
        description: "Failed to update bookmark",
        variant: "destructive",
      });
    }
  };

  const isBookmarked = (article: Article) => {
    return bookmarks.some((b) => b.url === article.url);
  };

  const handleSignOut = async () => {
    await signOut();
    navigate("/auth");
  };

  if (authLoading) {
    return (
      <div className="min-h-screen bg-news-gradient flex items-center justify-center">
        <Loader2 className="w-8 h-8 animate-spin text-accent" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-news-gradient">
      <Navbar
        showAnalytics={showAnalytics}
        showBookmarks={showBookmarks}
        bookmarksCount={bookmarks.length}
        onAnalyticsClick={() => {
          setShowAnalytics(!showAnalytics);
          setShowBookmarks(false);
        }}
        onBookmarksClick={() => {
          setShowBookmarks(!showBookmarks);
          setShowAnalytics(false);
        }}
        onSignOut={handleSignOut}
      />

      {/* Category Filter - Below Navbar */}
      <div className="container mx-auto px-4 pt-4">
        <CategoryFilter selected={category} onSelect={setCategory} />
      </div>

      {/* Main Content */}
      <main className="container mx-auto px-4 py-6">
        {/* Analytics View */}
        {showAnalytics && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-8"
          >
            <Analytics articles={articles} />
          </motion.div>
        )}

        {/* Bookmarks View */}
        {showBookmarks && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-8"
          >
            <BookmarksPanel
              bookmarks={bookmarks}
              onRemove={toggleBookmark}
              onClose={() => setShowBookmarks(false)}
            />
          </motion.div>
        )}

        {/* News Grid */}
        {!showAnalytics && !showBookmarks && (
          <>
            <div className="flex items-center gap-2 mb-6 animate-fade-in">
              <TrendingUp className="w-5 h-5 text-accent" />
              <h2 className="text-xl font-semibold text-foreground capitalize">
                {category} Headlines
              </h2>
              <span className="text-sm text-muted-foreground ml-auto">
                {articles.length} articles
              </span>
            </div>

            {loading ? (
              <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                {[...Array(6)].map((_, i) => (
                  <div
                    key={i}
                    className="h-96 bg-card rounded-xl animate-pulse"
                  />
                ))}
              </div>
            ) : (
              <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
                {articles.map((article, index) => (
                  <motion.div
                    key={index}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: index * 0.05 }}
                  >
                    <NewsCard
                      article={article}
                      isBookmarked={isBookmarked(article)}
                      onToggleBookmark={() => toggleBookmark(article)}
                    />
                  </motion.div>
                ))}
              </div>
            )}
          </>
        )}

        {!loading && articles.length === 0 && !showBookmarks && (
          <div className="text-center py-20 animate-fade-in">
            <p className="text-muted-foreground text-lg">
              No articles found. Try a different category.
            </p>
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="mt-20 py-6 border-t border-border bg-card/50">
        <div className="container mx-auto px-4 text-center text-sm text-muted-foreground">
          <p>Powered by NewsAPI.org • Built with ❤️ for news enthusiasts</p>
        </div>
      </footer>
    </div>
  );
};

export default Index;
