import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { QueryClient, QueryClientProvider } from 'react-query';
import { Provider } from 'react-redux';
import { store } from './store';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Clusters from './pages/Clusters';
import Deployments from './pages/Deployments';
import Templates from './pages/Templates';
import Monitoring from './pages/Monitoring';

const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#90caf9',
    },
    secondary: {
      main: '#ce93d8',
    },
  },
});

const queryClient = new QueryClient();

const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      {
        index: true,
        element: <Dashboard />,
      },
      {
        path: 'clusters',
        element: <Clusters />,
      },
      {
        path: 'deployments',
        element: <Deployments />,
      },
      {
        path: 'templates',
        element: <Templates />,
      },
      {
        path: 'monitoring',
        element: <Monitoring />,
      },
    ],
  },
]);

function App() {
  return (
    <Provider store={store}>
      <QueryClientProvider client={queryClient}>
        <ThemeProvider theme={darkTheme}>
          <CssBaseline />
          <RouterProvider router={router} />
        </ThemeProvider>
      </QueryClientProvider>
    </Provider>
  );
}

export default App;
