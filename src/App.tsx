import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import HomeVehiculos from './pages/web/InicioWeb'
import Vehiculos from './pages/app/PageVehiculo'
import Dashboard from './pages/app/HomeDashboard'
import PrivateRoute from './components/PrivateRoute'

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<HomeVehiculos />} /> 
        <Route 
          path="/dashboard" 
          element={
            <PrivateRoute rolesPermitidos={["Administrador", "Empleado"]}>
              <Dashboard />
            </PrivateRoute>
          } 
        />
        <Route 
          path="/vehiculos" 
          element={
            <PrivateRoute rolesPermitidos={["Administrador", "Empleado"]}>
              <Vehiculos />
            </PrivateRoute>
          } 
        />
      </Routes>
    </Router>
  )
}

export default App
