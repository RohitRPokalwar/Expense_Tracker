import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from "recharts";
import { Article } from "@/pages/Index";
import { BarChart3, TrendingUp, Hash } from "lucide-react";
import { motion } from "framer-motion";

interface AnalyticsProps {
  articles: Article[];
}

const COLORS = [
  "hsl(var(--accent))",
  "hsl(var(--primary))",
  "hsl(220 70% 50%)",
  "hsl(15 85% 70%)",
  "hsl(var(--success))",
];

const Analytics = ({ articles }: AnalyticsProps) => {
  // Count articles by source
  const sourceCount = articles.reduce((acc, article) => {
    const source = article.source.name;
    acc[source] = (acc[source] || 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  const sourceData = Object.entries(sourceCount)
    .map(([name, value]) => ({ name, value }))
    .sort((a, b) => b.value - a.value)
    .slice(0, 5);

  // Extract trending words from titles
  const getTrendingWords = () => {
    const stopWords = new Set([
      "the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for",
      "of", "with", "is", "are", "was", "were", "be", "been", "being",
      "have", "has", "had", "do", "does", "did", "will", "would", "could",
      "should", "may", "might", "can", "this", "that", "these", "those",
      "from", "by", "about", "as", "into", "through", "during", "after",
      "before", "up", "down", "out", "over", "under", "again", "further",
      "then", "once", "here", "there", "when", "where", "why", "how", "all",
      "both", "each", "few", "more", "most", "other", "some", "such", "no",
      "nor", "not", "only", "own", "same", "so", "than", "too", "very", "s",
      "t", "just", "it", "its", "new", "says",
    ]);

    const wordCount: Record<string, number> = {};
    
    articles.forEach((article) => {
      const words = article.title
        .toLowerCase()
        .replace(/[^\w\s]/g, "")
        .split(/\s+/);
      
      words.forEach((word) => {
        if (word.length > 3 && !stopWords.has(word)) {
          wordCount[word] = (wordCount[word] || 0) + 1;
        }
      });
    });

    return Object.entries(wordCount)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([word, count]) => ({ word, count }));
  };

  const trendingWords = getTrendingWords();

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <BarChart3 className="w-6 h-6 text-accent" />
        <h2 className="text-2xl font-bold text-foreground">News Analytics</h2>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        {/* Source Distribution Chart */}
        <Card className="border-border">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-accent" />
              Top News Sources
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              <PieChart>
                <Pie
                  data={sourceData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) =>
                    `${name}: ${(percent * 100).toFixed(0)}%`
                  }
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {sourceData.map((entry, index) => (
                    <Cell
                      key={`cell-${index}`}
                      fill={COLORS[index % COLORS.length]}
                    />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Trending Words */}
        <Card className="border-border">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Hash className="w-5 h-5 text-accent" />
              Trending Keywords
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {trendingWords.map((item, index) => (
                <motion.div
                  key={item.word}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: index * 0.05 }}
                  className="flex items-center gap-3"
                >
                  <div className="flex items-center justify-center w-8 h-8 rounded-full bg-accent/10 text-accent font-semibold text-sm">
                    {index + 1}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-1">
                      <span className="font-medium text-foreground capitalize">
                        {item.word}
                      </span>
                      <span className="text-sm text-muted-foreground">
                        {item.count} mentions
                      </span>
                    </div>
                    <div className="h-2 bg-secondary rounded-full overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: `${(item.count / trendingWords[0].count) * 100}%` }}
                        transition={{ duration: 0.5, delay: index * 0.05 }}
                        className="h-full bg-accent rounded-full"
                      />
                    </div>
                  </div>
                </motion.div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default Analytics;
