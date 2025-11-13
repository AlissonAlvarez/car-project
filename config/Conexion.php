<?php

class Conexion {

    public $conexionbd;
    public $sql;
    public $resultadobd;
    public $filasbd;
    public $id;

    /*     FUNCIÓN PARA CONECTAR BASE DE DATOS */

    public function abrir_conexion() {
        $this->conexionbd = new mysqli(BD_SERVIDOR, BD_USUARIO, BD_CONTRASENA, BD_BASEDATOS);
        $this->conexionbd->set_charset(BD_CHARSET);
        if ($this->conexionbd->connect_errno) {
            /* echo 'No se ha podido conectar a la Base de Datos'; */
        } else {
            /* echo 'Conectado exitosamente a la Base de Datos'; */
            return $this->conexionbd;
        }
    }

    /*     FUNCIÓN PARA DESCONECTAR BASE DE DATOS */

    public function cerrar_conexion() {
        $this->conexionbd->close();
    }

    public function consultar_informacion($sql) {
        $this->sql = $sql;
        $this->resultadobd = $this->conexionbd->query($this->sql);
        $this->filasbd = $this->conexionbd->affected_rows;
    }

    public function obtener_resultados() {
        return $this->resultadobd;
    }

    public function obtener_filas() {
        return $this->filasbd;
    }

}

?>