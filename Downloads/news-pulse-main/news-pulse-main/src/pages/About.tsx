import { motion } from "framer-motion";
import { TrendingUp, Zap, Shield, Users } from "lucide-react";
import Navbar from "@/components/Navbar";
import { useAuth } from "@/hooks/useAuth";
import { useNavigate } from "react-router-dom";

const About = () => {
  const { signOut } = useAuth();
  const navigate = useNavigate();

  const handleSignOut = async () => {
    await signOut();
    navigate("/auth");
  };

  const features = [
    {
      icon: TrendingUp,
      title: "Real-Time Updates",
      description: "Stay informed with the latest news from trusted sources, updated in real-time across multiple categories.",
    },
    {
      icon: Zap,
      title: "Lightning Fast",
      description: "Built with modern technology for blazing-fast performance and seamless user experience.",
    },
    {
      icon: Shield,
      title: "Secure & Private",
      description: "Your data is protected with enterprise-grade security. We prioritize your privacy above all.",
    },
    {
      icon: Users,
      title: "Personalized Experience",
      description: "Save your favorite articles, track reading analytics, and customize your news feed.",
    },
  ];

  return (
    <div className="min-h-screen bg-news-gradient">
      <Navbar onSignOut={handleSignOut} />
      
      <main className="container mx-auto px-4 py-12">
        {/* Hero Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-16"
        >
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ type: "spring", stiffness: 200, damping: 15 }}
            className="inline-block mb-6"
          >
            <div className="bg-gradient-to-br from-accent to-accent/80 p-4 rounded-2xl shadow-lg">
              <TrendingUp className="w-12 h-12 text-accent-foreground" />
            </div>
          </motion.div>
          
          <h1 className="text-4xl md:text-5xl font-bold mb-4 bg-gradient-to-r from-primary to-accent bg-clip-text text-transparent">
            About NewsPulse
          </h1>
          <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
            Your intelligent news companion that keeps you connected to what matters most in the world.
          </p>
        </motion.div>

        {/* Mission Section */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="mb-16 bg-card rounded-2xl p-8 md:p-12 shadow-lg border border-border"
        >
          <h2 className="text-3xl font-bold mb-4 text-foreground">Our Mission</h2>
          <p className="text-lg text-muted-foreground leading-relaxed">
            NewsPulse was created with a simple yet powerful vision: to make staying informed effortless and enjoyable. 
            In a world overflowing with information, we cut through the noise to deliver the headlines that matter most. 
            Our platform combines cutting-edge technology with elegant design to provide you with a news experience 
            that's both informative and delightful.
          </p>
        </motion.div>

        {/* Features Grid */}
        <div className="mb-16">
          <motion.h2
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="text-3xl font-bold text-center mb-12 text-foreground"
          >
            Why Choose NewsPulse?
          </motion.h2>
          
          <div className="grid md:grid-cols-2 gap-6">
            {features.map((feature, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 + index * 0.1 }}
                whileHover={{ y: -5, transition: { duration: 0.2 } }}
                className="bg-card rounded-xl p-6 shadow-md border border-border hover:shadow-xl transition-all"
              >
                <div className="flex items-start gap-4">
                  <div className="bg-accent/10 p-3 rounded-lg">
                    <feature.icon className="w-6 h-6 text-accent" />
                  </div>
                  <div>
                    <h3 className="text-xl font-semibold mb-2 text-foreground">
                      {feature.title}
                    </h3>
                    <p className="text-muted-foreground leading-relaxed">
                      {feature.description}
                    </p>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Technology Stack */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="bg-gradient-to-br from-accent/5 to-accent/10 rounded-2xl p-8 md:p-12 border border-accent/20"
        >
          <h2 className="text-3xl font-bold mb-4 text-foreground text-center">
            Built with Modern Technology
          </h2>
          <p className="text-lg text-muted-foreground text-center max-w-3xl mx-auto">
            NewsPulse leverages React, TypeScript, and modern cloud infrastructure to deliver a seamless, 
            responsive experience. Our backend infrastructure ensures reliable news delivery 
            with secure authentication and real-time updates.
          </p>
        </motion.div>
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

export default About;
