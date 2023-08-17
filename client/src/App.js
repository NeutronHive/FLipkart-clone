import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Home, NotFound } from './Components/default';
import { Box } from '@mui/material'

//components
import Header from './Components/Header/Header';
import DetailView from './Components/ItemDetails/DetailView';
import TemplateProvider from './templates/TemplateProvider';
import ContextProvider from './context/ContextProvider';
import Cart from './Components/Cart/Cart';
import Flipgem from './Components/Flipgem';
import Coupon from './Components/Coupon';
import RulesPage from './Components/RulesAndRegulations/RulesAndRegulations';
import { useEffect } from 'react';

function App() {

  return (
    <TemplateProvider>
      <ContextProvider>
        <BrowserRouter>
          <Header />
          <Box style={{marginTop: 54}}>
            <Routes>
              <Route path= '/' element={<Home />} />
              <Route path= '/cart' element={<Cart />} />
              <Route path= '/product/:id' element={<DetailView />} />
              <Route path= '/flipgem' element={<Flipgem />} />
              <Route path= '/coupons' element={<Coupon />} />
              <Route path= '/rulesandregulations' element={<RulesPage />} />
            </Routes>
          </Box>
        </BrowserRouter>
      </ContextProvider>
    </TemplateProvider>
  );
}

export default App;
