// Importa el módulo principal de CDS (Core Data Services) de SAP
const cds = require("@sap/cds");

// Extrae la entidad "Orders" del modelo definido en el namespace "com.training"
const { Orders } = cds.entities("com.training");

// Exporta una función que se ejecutará al inicializar el servicio (srv)
module.exports = (srv) => {

    // Operación READ personalizada para la acción o función "GetOrders"
    srv.on("READ", "GetOrders", async (req) => {
        try {
            // Consulta todos los registros de la entidad Orders

            if (req.data.ClientEmail !== undefined) {
                return await SELECT.from`com.training.Orders`
                    .where`ClientEmail = ${req.data.ClientEmail}`;
            }
            return await SELECT.from(Orders);
        } catch (error) {
            // Manejo del error con template string correctamente interpolado
            req.error(500, 'Error al leer las órdenes: ${error.message}');
        }
    });

    srv.after("READ", "GetOrders", (data) => {
        return data.map((order) => (order.Reviewed = true));
    });
};