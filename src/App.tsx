import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import HomeVehiculos from './pages/web/InicioWeb'
import Vehiculos from './pages/app/PageVehiculo'
import InicioWeb from './pages/web/InicioWeb'

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomeVehiculos />} />
        <Route path="/dashboard" element={<InicioWeb />} />
        <Route path="/vehiculos" element={<Vehiculos />} />
      </Routes>
    </Router>
  )
}

export default App
