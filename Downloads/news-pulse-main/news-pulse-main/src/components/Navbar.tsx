import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { Newspaper, Menu, X, LogOut, Bookmark, BarChart3, Settings } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/hooks/useAuth";
import SettingsModal from "./SettingsModal";

interface NavbarProps {
  showAnalytics?: boolean;
  showBookmarks?: boolean;
  bookmarksCount?: number;
  onAnalyticsClick?: () => void;
  onBookmarksClick?: () => void;
  onSignOut?: () => void;
}

const Navbar = ({
  showAnalytics,
  showBookmarks,
  bookmarksCount = 0,
  onAnalyticsClick,
  onBookmarksClick,
  onSignOut,
}: NavbarProps) => {
  const [isOpen, setIsOpen] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);
  const location = useLocation();
  const { user } = useAuth();

  const navLinks = [
    { path: "/", label: "Home" },
    { path: "/about", label: "About" },
    { path: "/contact", label: "Contact" },
  ];

  const isActive = (path: string) => location.pathname === path;

  return (
    <motion.header
      initial={{ y: -100 }}
      animate={{ y: 0 }}
      className="sticky top-0 z-50 bg-card/80 backdrop-blur-lg border-b border-border shadow-sm"
    >
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link to="/">
            <motion.div
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="flex items-center gap-3 cursor-pointer"
            >
              <div className="bg-gradient-to-br from-accent to-accent/80 p-2 rounded-xl shadow-lg">
                <Newspaper className="w-6 h-6 text-accent-foreground" />
              </div>
              <div>
                <h1 className="text-2xl font-bold bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
                  NewsPulse
                </h1>
                <p className="text-xs text-muted-foreground">Trending Headlines Analyzer</p>
              </div>
            </motion.div>
          </Link>

          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center gap-6">
            {navLinks.map((link) => (
              <Link key={link.path} to={link.path}>
                <motion.div
                  whileHover={{ y: -2 }}
                  className="relative"
                >
                  <span
                    className={`text-sm font-medium transition-colors ${
                      isActive(link.path)
                        ? "text-accent"
                        : "text-foreground hover:text-accent"
                    }`}
                  >
                    {link.label}
                  </span>
                  {isActive(link.path) && (
                    <motion.div
                      layoutId="navbar-indicator"
                      className="absolute -bottom-1 left-0 right-0 h-0.5 bg-accent rounded-full"
                      transition={{ type: "spring", stiffness: 380, damping: 30 }}
                    />
                  )}
                </motion.div>
              </Link>
            ))}
          </nav>

          {/* Action Buttons */}
          <div className="hidden md:flex items-center gap-2">
            {user && location.pathname === "/" && (
              <>
                {onAnalyticsClick && (
                  <Button
                    variant={showAnalytics ? "default" : "outline"}
                    size="sm"
                    onClick={onAnalyticsClick}
                    className="gap-2 transition-all hover:shadow-md"
                  >
                    <BarChart3 className="w-4 h-4" />
                    Analytics
                  </Button>
                )}
                {onBookmarksClick && (
                  <Button
                    variant={showBookmarks ? "default" : "outline"}
                    size="sm"
                    onClick={onBookmarksClick}
                    className="gap-2 relative transition-all hover:shadow-md"
                  >
                    <Bookmark className="w-4 h-4" />
                    Bookmarks
                    {bookmarksCount > 0 && (
                      <motion.span
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        className="absolute -top-1 -right-1 bg-accent text-accent-foreground text-xs w-5 h-5 rounded-full flex items-center justify-center font-semibold"
                      >
                        {bookmarksCount}
                      </motion.span>
                    )}
                  </Button>
                )}
              </>
            )}
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setSettingsOpen(true)}
              className="gap-2 transition-all hover:shadow-md"
            >
              <Settings className="w-4 h-4" />
              Settings
            </Button>
            {user && onSignOut && (
              <Button
                variant="ghost"
                size="sm"
                onClick={onSignOut}
                className="gap-2 transition-all hover:bg-destructive/10 hover:text-destructive"
              >
                <LogOut className="w-4 h-4" />
                Logout
              </Button>
            )}
            {!user && location.pathname !== "/auth" && (
              <Link to="/auth">
                <Button size="sm" className="gap-2">
                  Login
                </Button>
              </Link>
            )}
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={() => setIsOpen(!isOpen)}
            className="md:hidden p-2 hover:bg-secondary rounded-lg transition-colors"
          >
            {isOpen ? (
              <X className="w-6 h-6 text-foreground" />
            ) : (
              <Menu className="w-6 h-6 text-foreground" />
            )}
          </button>
        </div>

        {/* Mobile Menu */}
        <AnimatePresence>
          {isOpen && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              className="md:hidden overflow-hidden"
            >
              <nav className="flex flex-col gap-2 py-4">
                {navLinks.map((link) => (
                  <Link
                    key={link.path}
                    to={link.path}
                    onClick={() => setIsOpen(false)}
                  >
                    <motion.div
                      whileTap={{ scale: 0.95 }}
                      className={`px-4 py-2 rounded-lg transition-colors ${
                        isActive(link.path)
                          ? "bg-accent text-accent-foreground"
                          : "hover:bg-secondary"
                      }`}
                    >
                      {link.label}
                    </motion.div>
                  </Link>
                ))}
                {user && location.pathname === "/" && (
                  <>
                    {onAnalyticsClick && (
                      <Button
                        variant={showAnalytics ? "default" : "outline"}
                        onClick={() => {
                          onAnalyticsClick();
                          setIsOpen(false);
                        }}
                        className="justify-start gap-2"
                      >
                        <BarChart3 className="w-4 h-4" />
                        Analytics
                      </Button>
                    )}
                    {onBookmarksClick && (
                      <Button
                        variant={showBookmarks ? "default" : "outline"}
                        onClick={() => {
                          onBookmarksClick();
                          setIsOpen(false);
                        }}
                        className="justify-start gap-2 relative"
                      >
                        <Bookmark className="w-4 h-4" />
                        Bookmarks
                        {bookmarksCount > 0 && (
                          <span className="ml-auto bg-accent text-accent-foreground text-xs px-2 py-1 rounded-full font-semibold">
                            {bookmarksCount}
                          </span>
                        )}
                      </Button>
                    )}
                  </>
                )}
                <Button
                  variant="ghost"
                  onClick={() => {
                    setSettingsOpen(true);
                    setIsOpen(false);
                  }}
                  className="justify-start gap-2"
                >
                  <Settings className="w-4 h-4" />
                  Settings
                </Button>
                {user && onSignOut && (
                  <Button
                    variant="ghost"
                    onClick={() => {
                      onSignOut();
                      setIsOpen(false);
                    }}
                    className="justify-start gap-2 text-destructive hover:bg-destructive/10"
                  >
                    <LogOut className="w-4 h-4" />
                    Logout
                  </Button>
                )}
                {!user && location.pathname !== "/auth" && (
                  <Link to="/auth" onClick={() => setIsOpen(false)}>
                    <Button className="w-full">Login</Button>
                  </Link>
                )}
              </nav>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
      <SettingsModal open={settingsOpen} onOpenChange={setSettingsOpen} />
    </motion.header>
  );
};

export default Navbar;
