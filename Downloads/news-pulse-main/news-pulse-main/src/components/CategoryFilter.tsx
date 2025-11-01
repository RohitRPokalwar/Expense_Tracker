import { Button } from "@/components/ui/button";
import { motion } from "framer-motion";
import { Zap, Gamepad2, Briefcase, Heart, Globe } from "lucide-react";

interface CategoryFilterProps {
  selected: string;
  onSelect: (category: string) => void;
}

const categories = [
  { id: "general", label: "General", icon: Globe },
  { id: "technology", label: "Technology", icon: Zap },
  { id: "sports", label: "Sports", icon: Gamepad2 },
  { id: "business", label: "Business", icon: Briefcase },
  { id: "health", label: "Health", icon: Heart },
];

const CategoryFilter = ({ selected, onSelect }: CategoryFilterProps) => {
  return (
    <div className="flex gap-2 mt-4 overflow-x-auto pb-2 scrollbar-hide">
      {categories.map((cat) => {
        const Icon = cat.icon;
        const isSelected = selected === cat.id;
        
        return (
          <motion.div
            key={cat.id}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <Button
              variant={isSelected ? "default" : "outline"}
              size="sm"
              onClick={() => onSelect(cat.id)}
              className={`gap-2 whitespace-nowrap ${
                isSelected ? "shadow-card-hover" : ""
              }`}
            >
              <Icon className="w-4 h-4" />
              {cat.label}
            </Button>
          </motion.div>
        );
      })}
    </div>
  );
};

export default CategoryFilter;
