import type { NextPage } from 'next';
import Head from 'next/head';

const Home: NextPage = () => {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center py-2">
      <Head>
        <title>Quiz App</title>
        <link rel="icon" href="/favicon.ico" />
      </Head>

      <main className="flex flex-col items-center justify-center w-full flex-1 px-20 text-center">
        <h1 className="text-6xl font-bold">
          Welcome to <span className="text-blue-600">Quiz App!</span>
        </h1>

        <p className="mt-3 text-2xl">
          Get started by exploring our quizzes
        </p>

        <div className="flex flex-wrap items-center justify-around max-w-4xl mt-6 sm:w-full">
          
            href="/auth/login"
            className="p-6 mt-6 text-left border w-96 rounded-xl hover:text-blue-600 focus:text-blue-600"
          >
            <h3 className="text-2xl font-bold">Login &rarr;</h3>
            <p className="mt-4 text-xl">
              Access your account to take quizzes and track your progress.
            </p>
          </a>

          
            href="/auth/register"
            className="p-6 mt-6 text-left border w-96 rounded-xl hover:text-blue-600 focus:text-blue-600"
          >
            <h3 className="text-2xl font-bold">Register &rarr;</h3>
            <p className="mt-4 text-xl">
              Create a new account to start your quiz journey!
            </p>
          </a>
        </div>
      </main>

      <footer className="flex items-center justify-center w-full h-24 border-t">
        
          className="flex items-center justify-center"
          href="https://github.com/yourusername/quiz-app"
          target="_blank"
          rel="noopener noreferrer"
        >
          Powered by Quiz App Team
        </a>
      </footer>
    </div>
  );
};

export default Home;
