// Importa el módulo principal de CDS (Core Data Services) de SAP
const { error } = require("@sap/cds");
const cds = require("@sap/cds");
const { where } = require("@sap/cds/lib/ql/cds-ql");

// Extrae la entidad "Orders" del modelo definido en el namespace "com.training"
const { Orders } = cds.entities("com.training");

// Exporta una función que se ejecutará al inicializar el servicio (srv)
module.exports = (srv) => {
    //=========================================================
    //                       READ
    //=========================================================

    // Operación READ personalizada para la acción o función "GetOrders"
    srv.on("READ", "Orders", async (req) => {
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

    // Hook AFTER que se ejecuta después de una operación READ sobre la función "GetOrders"
    srv.after("READ", "Orders", (data) => {

        // Recorre cada objeto del array de órdenes recibido
        // y agrega (o modifica) la propiedad "Reviewed" poniéndola en true
        // IMPORTANTE: se debe retornar el objeto completo, no solo el valor asignado
        return data.map((order) => (
            order.Reviewed = true)); // Marca la orden como revisada

    });

    //=========================================================
    //                       CREATE
    //=========================================================
    // Define un manejador para el evento CREATE del servicio, específicamente para la entidad "CreateOrder"
    // Middleware que se ejecuta cuando se invoca la acción CREATE sobre la entidad "CreateOrder"
    srv.on("CREATE", "Orders", async (req) => {

        // Ejecutamos una transacción de CDS basada en la solicitud actual
        let returnData = await cds
            .transaction(req) // Inicia una transacción en el contexto de la solicitud
            .run(
                // Ejecuta un INSERT sobre la entidad 'Orders' con los datos recibidos
                INSERT.into(Orders).entries({
                    ClientEmail: req.data.ClientEmail,
                    FirstName: req.data.FirstName,
                    LastName: req.data.LastName,
                    CreatedOn: req.data.CreatedOn,
                    Reviewed: req.data.Reviewed,
                    Approved: req.data.Approved,
                })
            )
            // Manejo de la promesa tras ejecutar el INSERT
            .then((resolve, reject) => {
                console.log("Resolve", resolve); // Muestra el resultado exitoso
                console.log("Reject", reject);   // Muestra si hubo un rechazo

                // Valida si 'cds.resolve' está definido (aunque esto no suele ser necesario en este contexto)
                if (typeof cds.resolve !== "undefined") {
                    // Si se resolvió correctamente, se devuelve el mismo objeto recibido en la petición
                    return req.data;
                } else {
                    // Si no, lanza un error con código 409 (conflicto)
                    req.error(409, "Record not Inserted");
                }
            })
            // Manejo de errores si falla el INSERT
            .catch((err) => {
                // ⚠️ Aquí hay un error: `resolve` y `reject` no están definidos en este contexto
                console.log("Resolve", resolve);
                console.log("Reject", reject);
            });

        // Muestra el valor de retorno antes de finalizar el handler
        console.log("Before End ", returnData);

        // Retorna la respuesta al cliente
        return returnData;
    });


    //=========================================================
    //                       BEFORE
    //=========================================================
    // Middleware que se ejecuta *antes* de que se cree una entidad del tipo "CreateOrder"
    srv.before("CREATE", "Orders", (req) => {
        // Establece la fecha actual (solo el día, sin hora) en el campo 'CreatedOn' del objeto que se va a crear
        // new Date().toISOString() genera una cadena con la fecha y hora actual en formato ISO (ej: "2025-06-19T15:30:00.000Z")
        // .slice(0, 10) toma solo los primeros 10 caracteres para obtener "YYYY-MM-DD"
        req.data.CreatedOn = new Date().toISOString().slice(0, 10);

        // Retorna el objeto de la solicitud modificado
        return req;
    });
    //=========================================================
    //                       UPDATE
    //=========================================================

    // Handler para el evento UPDATE sobre la entidad "UpdateOrder"
    srv.on("UPDATE", "Orders", async (req) => {
        // Ejecutamos una transacción con UPDATE en la entidad Orders
        let returnData = await cds
            .transaction(req)
            .run(
                [
                    UPDATE(Orders, req.data.ClientEmail)
                        .set({
                            FirstName: req.data.FirstName,
                            LastName: req.data.LastName
                        })
                ]
            )
            .then((resolve, reject) => {
                console.log("Resolve: ", resolve);
                console.log("Reject: ", reject);
                if (cds.resolve[0] == 0) {
                    // Si no se actualizó ningún registro, lanzar error
                    req.error(409, "Order not found or no changes applied");
                }
            })
            .catch((error) => {
                console.log(error);
                req.error(error.code, error.message);
            });
        console.log("Before End", returnData);
        return await returnData;
    });

    //=========================================================
    //                       DELETE
    //=========================================================

    srv.on("DELETE", "Orders", async (req) => {
        let returnData = await cds
            .transaction(req)
            .run(
                DELETE.from(Orders).where({
                    ClientEmail: req.data.ClientEmail
                })
            )
            .then((resolve, reject) => {
                console.log("Resolve: ", resolve);
                console.log("Reject: ", reject);

                if (resolve !== 1) {
                    req.error(409, "Record Not Found");
                }
            })
            .catch((error) => {
                console.log(error);
                req.error(error.code, error.message);
            });
        console.log("Before End", returnData);
        return await returnData;
    });
    //=========================================================
    //                       Function
    //=========================================================

    srv.on("getClientTaxRate", async (req) => {
        //No server side-effect
        const { clientEmail } = req.data;
        const db = srv.transaction(req);

        const results = await db
            .read(Orders, ["Country_code"])
            .where({ ClientEmail: clientEmail });

        switch (results[0].Country_code) {
            case "ES":
                return 21.5;
            case "UK":
                return 24.6;
            default:
                break;
        }
    });
};
