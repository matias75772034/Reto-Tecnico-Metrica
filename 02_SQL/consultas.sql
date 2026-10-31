/* ==========================================================================
   Reto Técnico QA - Consultas SQL Server
   Tablas: Depositos, Usuarios (Anexo 2)
   ========================================================================== */

/* --------------------------------------------------------------------------
   8. Caso de prueba: Verificar depósitos consultando la tabla Depositos
      - Ordenar mostrando primero el último registro generado
      - Montos entre 10 y 100
      - Estado "Exitoso"
      - Moneda Soles (PEN)
   -------------------------------------------------------------------------- */
SELECT  d.IdDeposito,
        d.UsuarioId,
        d.Monto,
        d.Moneda,
        d.Estado,
        d.FechaCreacion
FROM    Depositos AS d
WHERE   d.Monto BETWEEN 10 AND 100
  AND   d.Estado = 'Exitoso'
  AND   d.Moneda = 'PEN'
ORDER BY d.FechaCreacion DESC, d.IdDeposito DESC;


/* --------------------------------------------------------------------------
   9. Caso de prueba: Verificar depósitos relacionados con Usuarios (INNER JOIN)
      - Usuario Testcalimaco35
      - Ordenar mostrando primero el último registro generado
      - Monto de 100
      - Estado "Pendiente"
      - Moneda Soles (PEN)
   -------------------------------------------------------------------------- */
SELECT  u.IdUsuario,
        u.NombreUsuario,
        u.Email,
        d.IdDeposito,
        d.Monto,
        d.Moneda,
        d.Estado,
        d.FechaCreacion
FROM    Depositos AS d
INNER JOIN Usuarios AS u
        ON u.IdUsuario = d.UsuarioId
WHERE   u.NombreUsuario = 'Testcalimaco35'
  AND   d.Monto = 100
  AND   d.Estado = 'Pendiente'
  AND   d.Moneda = 'PEN'
ORDER BY d.FechaCreacion DESC, d.IdDeposito DESC;
