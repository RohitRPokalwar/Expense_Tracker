# NewsPulse - Trending Headlines Analyzer

[![React](https://img.shields.io/badge/React-18.3.1-blue.svg)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8.3-blue.svg)](https://www.typescriptlang.org/)
[![Vite](https://img.shields.io/badge/Vite-5.4.19-yellow.svg)](https://vitejs.dev/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-green.svg)](https://www.mongodb.com/atlas)
[![Express](https://img.shields.io/badge/Express-4.x-lightgrey.svg)](https://expressjs.com/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind_CSS-3.4.17-blue.svg)](https://tailwindcss.com/)

A modern, responsive news aggregator that delivers trending headlines with visual analytics, bookmarking, AI-powered summarization, and personalized recommendations. Built with React, TypeScript, Express.js, and MongoDB for a seamless user experience.

## 🌟 Features

- **Real-Time News Updates**: Stay informed with the latest news from trusted sources across multiple categories
- **Visual Analytics**: Explore news trends with interactive charts and keyword analysis
- **Bookmark Management**: Save and organize your favorite articles with cloud sync
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Dark/Light Mode**: Toggle between themes for comfortable reading
- **Secure Authentication**: User accounts with Supabase for personalized experience
- **Category Filtering**: Browse news by categories like General, Technology, Sports, Business, and Health
- **Source Tracking**: View news distribution by publication source

## 🚀 Tech Stack

### Frontend

- **React 18** - Modern React with hooks and concurrent features
- **TypeScript** - Type-safe development
- **Vite** - Fast build tool and development server
- **Tailwind CSS** - Utility-first CSS framework
- **Framer Motion** - Smooth animations and transitions
- **React Router** - Client-side routing
- **React Query** - Data fetching and caching
- **Recharts** - Data visualization components

### UI Components

- **Radix UI** - Accessible, unstyled UI primitives
- **shadcn/ui** - Beautiful, customizable components
- **Lucide React** - Modern icon library

### Backend & Database

- **Express.js** - RESTful API server
- **MongoDB Atlas** - NoSQL database for data storage
- **Mongoose** - MongoDB object modeling
- **JWT** - JSON Web Token authentication
- **OpenAI API** - AI-powered article summarization
- **NewsAPI** - External news data provider

### Development Tools

- **ESLint** - Code linting
- **PostCSS** - CSS processing
- **TypeScript** - Type checking
- **Vite Plugin React SWC** - Fast React compilation

## 📋 Prerequisites

Before running this project, make sure you have the following installed:

- **Node.js** (version 18 or higher)
- **npm** or **yarn** or **bun**
- **Git**

## 🛠️ Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/newspulse.git
   cd newspulse
   ```

2. **Install dependencies**

   ```bash
   npm install
   # or
   yarn install
   # or
   bun install
   ```

3. **Set up environment variables**

   Create a `.env.local` file in the root directory for frontend:

   ```env
   VITE_API_BASE_URL=http://localhost:5000/api
   ```

   Create a `.env` file in the `OneFolder` directory for backend:

   ```env
   MONGODB_URI=your_mongodb_atlas_connection_string
   OPENAI_API_KEY=your_openai_api_key
   NEWS_API_KEY=your_newsapi_key
   JWT_SECRET=your_jwt_secret_here
   PORT=5000
   ```

4. **Set up MongoDB Atlas**

   - Create a MongoDB Atlas account and cluster
   - Get your connection string and add it to the `.env` file
   - Create a database named `newsapp`

5. **Start the backend server**

   ```bash
   cd OneFolder
   npm start
   ```

   The backend will be available at `http://localhost:5000`

6. **Start the development server**

   ```bash
   npm run dev
   # or
   yarn dev
   # or
   bun dev
   ```

   The app will be available at `http://localhost:8080`

## 📖 Usage

### For Users

1. **Sign Up/Login**: Create an account or log in to access personalized features
2. **Browse News**: View trending headlines in your selected category
3. **Bookmark Articles**: Click the bookmark icon on any article to save it
4. **View Analytics**: Access the analytics panel to see news trends and source distribution
5. **Manage Bookmarks**: View and remove saved articles from the bookmarks panel
6. **Theme Toggle**: Switch between light and dark modes in settings

### For Developers

- **Development**: `npm run dev` - Start development server
- **Build**: `npm run build` - Build for production
- **Preview**: `npm run preview` - Preview production build
- **Lint**: `npm run lint` - Run ESLint

## 🔧 Configuration

### Environment Variables

| Variable            | Description                         | Required |
| ------------------- | ----------------------------------- | -------- |
| `VITE_API_BASE_URL` | Backend API base URL                | Yes      |
| `MONGODB_URI`       | MongoDB Atlas connection string     | Yes      |
| `OPENAI_API_KEY`    | OpenAI API key for summarization    | Yes      |
| `NEWS_API_KEY`      | NewsAPI key for news fetching       | Yes      |
| `JWT_SECRET`        | JWT secret for authentication       | Yes      |
| `PORT`              | Backend server port (default: 5000) | No       |

### MongoDB Setup

The project uses MongoDB Atlas for data storage. The database schema includes:

- `users` collection: User authentication and profile information
- `articles` collection: News articles with metadata
- `bookmarks` collection: User-saved articles
- `interactions` collection: User interactions for recommendations

API Endpoints:

- `GET /api/news`: Fetches news from NewsAPI and stores in database
- `GET /api/bookmarks`: Retrieves user bookmarks
- `POST /api/bookmarks`: Adds/removes bookmarks
- `GET /api/recommendations`: Generates personalized recommendations
- `POST /api/summarize`: AI-powered article summarization
- `POST /api/auth/register`: User registration
- `POST /api/auth/login`: User authentication

## 🚀 Deployment

### Vercel (Recommended)

1. Connect your GitHub repository to Vercel
2. Add environment variables in Vercel dashboard
3. Deploy automatically on push

### Other Platforms

The app can be deployed to any static hosting service like Netlify, GitHub Pages, or AWS S3.

For production builds:

```bash
npm run build
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

### Development Guidelines

- Follow the existing code style
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Ensure TypeScript types are properly defined

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **NewsAPI** for providing news data
- **MongoDB Atlas** for database services
- **OpenAI** for AI-powered summarization
- **shadcn/ui** for beautiful UI components
- **Tailwind CSS** for styling utilities
- **Framer Motion** for animations

---

**Built with ❤️ for news enthusiasts**
