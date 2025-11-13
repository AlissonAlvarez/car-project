import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Dashboard from './pages/HomeDashboard'
import Vehiculos from './pages/PageVehiculo'

function App() {

  return (
    <Router>
      <Routes>
        <Route path="/" element={<Dashboard/>} />
        <Route path="/vehiculos" element={<Vehiculos/>} />
      </Routes>
    </Router>
  )
}

export default App
