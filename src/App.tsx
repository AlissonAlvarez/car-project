import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import HomeVehiculos from './pages/web/InicioWeb'
import Vehiculos from './pages/app/PageVehiculo'
import Dashboard from './pages/app/HomeDashboard'

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomeVehiculos />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/vehiculos" element={<Vehiculos />} />
      </Routes>
    </Router>
  )
}

export default App
