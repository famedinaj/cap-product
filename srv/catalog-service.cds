// Importación del esquema de base de datos
using {com.famj as famj} from '../db/schema';
// using {com.training as training} from '../db/training'; // Comentado por no usarse actualmente

// Comentario útil:
// Para comentar líneas: Ctrl + K + C
// Para descomentar líneas: Ctrl + K + U

//====================================================================
//                   Definición del Servicio CatalogService
//====================================================================

// ⚠️ OPCIÓN ALTERNATIVA (comentada): definición por proyecciones directas
/*
service CatalogService {
   entity Products       as projection on famj.materials.Products;
   entity Suppliers      as projection on famj.Sales.Suppliers;
   entity UnitOfMeasures as projection on famj.materials.UnitOfMeasures;
   entity Currency       as projection on famj.materials.Currencies;
   entity DimensionUnit  as projection on famj.materials.DimensionUnit;
   entity Category       as projection on famj.materials.Categories;
   entity SalesData      as projection on famj.Sales.SalesData;
   entity Reviews        as projection on famj.materials.ProductReviews;
   entity Order          as projection on famj.Sales.Orders;
   entity OrderItem      as projection on famj.Sales.OrdersItems;
   entity car            as projection on famj.car;
   entity Course         as projection on training.Course;
}
*/

// ✅ DEFINICIÓN RECOMENDADA: por selección (`select from`) permite alias y control más fino

define service CatalogService {

   //=========================================================
   //                       Producto
   //=========================================================
   entity Product           as
      select from famj.reports.Products {
         ID,
         Name          as ProductName     @mandatory, // Alias
         Description                      @mandatory,
         ImageUrl,
         ReleaseDate,
         DiscontinuedDate,
         Price                            @mandatory,
         Height,
         Width,
         Depth,
         Quantity                         @(
            mandatory,
            assert.range: [
               0.00,
               20.00
            ]
         ),
         // Asociaciones con alias más semánticos
         UnitOfMeasure as ToUnitOfMeasure @mandatory,
         Currency      as ToCurrency      @mandatory,
         Category      as ToCategory      @mandatory,
         Category.Name as Category        @readonly, // Campo derivado de entidad asociada
         DimensionUnit as ToDimensionUnit,
         // Asociaciones a otras entidades
         SalesData,
         Supplier,
         Reviews,
         Rating,
         StockAvailability,
         ToStockAvailability
      };

   //=========================================================
   //                       Proveedor
   //=========================================================
   @readonly
   entity Supplier          as
      select from famj.Sales.Suppliers {
         ID,
         Name,
         Email,
         Phone,
         Fax,
         Product as ToProduct // Relación inversa
      };

   //=========================================================
   //                       Reseñas de productos
   //=========================================================
   entity Reviews           as
      select from famj.materials.ProductReviews {
         ID,
         Name,
         Rating,
         Comment,
         createdAt,
         Product as ToProduct
      };

   //=========================================================
   //                       Ventas
   //=========================================================
   @readonly
   entity SalesData         as
      select from famj.Sales.SalesData {
         ID,
         DeliveryDate,
         Revenue,
         Currency.ID           as CurrencyKey,
         DeliveryM.ID          as DeliveryMonthId,
         DeliveryM.Description as DeliveryMonth,
         Product               as ToProduct
      };

   //=========================================================
   //                       Disponibilidad en inventario
   //=========================================================
   entity StockAvailability as
      select from famj.materials.StockAvailability {
         ID,
         Description,
         Product as ToProduct
      };

   //=========================================================
   //                     Ayudas de Búsqueda (Value Helps)
   //=========================================================

   // Categorías para dropdowns
   @readonly
   entity VH_Categories     as
      select from famj.materials.Categories {
         ID   as Code,
         Name as Text
      };

   // Monedas para dropdowns
   @readonly
   entity VH_Currencies     as
      select from famj.materials.Currencies {
         ID          as Code,
         Description as Text
      };

   // Unidades de medida
   @readonly
   entity VH_UnitOfMeasure  as
      select from famj.materials.UnitOfMeasures {
         ID          as Code,
         Description as Text
      };

   // Unidades de dimensión
   //Selección con Postfix
   @readonly
   entity VH_DimensionUnits as
      select
         ID          as Code,
         Description as Text

      from famj.materials.DimensionUnit;
}

//Expresiones de Ruta
define service MyService {

   entity SuppliersProduct as
      select from famj.materials.Products[Name = 'Bread']{
         *, //Selector Inteligente
         Name,
         Description,
         Supplier.Address
      }
      where
         Supplier.Address.PostalCode = 98074;

   entity SuppliersToSales as
      select
         Supplier.Email,
         Category.Name,
         SalesData.Currency.ID,
         SalesData.Currency.Description
      from famj.materials.Products;


   //=========================================================
   //                 Filtro INFIX - Left Join
   //=========================================================

   entity EntityInfix      as
      select Supplier[Name = 'Exotic Liquids'].Phone from famj.materials.Products
      where
         Products.Name = 'Bread';

   entity EntityJoin       as
      select Phone from famj.materials.Products as P
      left join famj.Sales.Suppliers as ss
         on(
             ss.ID   = P.Supplier.ID
         )
         and ss.Name = 'Exotic Liquids'
      where
         P.Name = 'Bread';
}

//=========================================================
//                       Agrupaciones
//=========================================================
define service Reports {
   entity AvarageRating as projection on famj.reports.AvarageRating;

   //=========================================================
   //                       Casting
   //=========================================================

   entity EntityCasting as
      select
         cast(
            Price as Integer
         )     as Price,
         Price as Price2 : Integer
      from famj.materials.Products;


   //=========================================================
   //                       Exists
   //=========================================================
   entity EntityExists  as
      select from famj.materials.Products {
         Name
      }
      where
         exists Supplier[Name = 'Tokyo Traders'];
}
