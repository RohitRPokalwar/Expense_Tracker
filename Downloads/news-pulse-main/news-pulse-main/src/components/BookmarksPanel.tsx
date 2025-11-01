import { X, Bookmark, Trash2 } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Article } from "@/pages/Index";
import NewsCard from "./NewsCard";

interface BookmarksPanelProps {
  bookmarks: Article[];
  onRemove: (article: Article) => void;
  onClose: () => void;
}

const BookmarksPanel = ({ bookmarks, onRemove, onClose }: BookmarksPanelProps) => {
  return (
    <div className="animate-fade-in-up">
      <Card className="border-border">
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle className="flex items-center gap-2">
              <Bookmark className="w-5 h-5 text-accent" />
              Your Bookmarks
              <span className="text-sm font-normal text-muted-foreground">
                ({bookmarks.length} saved)
              </span>
            </CardTitle>
            <Button variant="ghost" size="icon" onClick={onClose}>
              <X className="w-5 h-5" />
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {bookmarks.length === 0 ? (
            <div className="text-center py-12">
              <Bookmark className="w-16 h-16 mx-auto mb-4 text-muted-foreground opacity-50" />
              <h3 className="text-lg font-semibold text-foreground mb-2">
                No bookmarks yet
              </h3>
              <p className="text-muted-foreground">
                Start bookmarking articles to read them later
              </p>
            </div>
          ) : (
            <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
              {bookmarks.map((article, index) => (
                <div
                  key={index}
                  className="animate-fade-in-up"
                  style={{ animationDelay: `${index * 0.05}s` }}
                >
                  <NewsCard
                    article={article}
                    isBookmarked={true}
                    onToggleBookmark={() => onRemove(article)}
                  />
                </div>
              ))}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default BookmarksPanel;
