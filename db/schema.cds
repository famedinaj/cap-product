namespace com.famj;

//====================================================================
//                         Aspectos Comunes y Tipos
//====================================================================

// Importar aspectos comunes: cuid (UUID) y managed (timestamps, createdBy, etc.)
using {
    cuid,
    managed
} from '@sap/cds/common';

// Tipo personalizado: nombre corto de hasta 20 caracteres
define type Name   : String(20);
// Tipo personalizado para decimales
type Dec           : Decimal(16, 2);
// Tipo localizado reutilizable para nombres
type LocalizedName : localized String;

// Tipo estructurado para direcciones postales
define type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

context materials {

    //=========================================================
    //                     Entidad Products
    //=========================================================
    entity Products : cuid, managed {
        Name              : LocalizedName; // Nombre localizado
        Description       : localized String not null; // Descripción obligatoria
        ImageUrl          : String; // URL de la imagen
        ReleaseDate       : DateTime default $now; // Fecha de lanzamiento por defecto
        DiscontinuedDate  : DateTime; // Fecha de descontinuación
        Price             : Dec; // Precio
        Height            : type of Price; // Altura (referencia al tipo Price)
        Width             : Decimal(16, 2); // Ancho
        Depth             : Decimal(16, 2); // Profundidad
        Quantity          : Decimal(16, 2); // Cantidad disponible

        // Asociaciones Administradas (clave foránea implícita)
        Supplier          : Association to one Sales.Suppliers;
        UnitOfMeasure     : Association to UnitOfMeasures;
        Currency          : Association to Currencies;
        DimensionUnit     : Association to DimensionUnit;
        Category          : Association to Categories;
        StockAvailability : Association to StockAvailability;

        // Asociaciones a múltiples registros
        SalesData         : Association to many Sales.SalesData
                                on SalesData.Product = $self;
        Reviews           : Association to many ProductReviews
                                on Reviews.Product = $self;
    };

    // Extensión a Products con campos adicionales
    extend Products with {
        PriceCondition     : String(2); // Condición de precio
        PriceDetermination : String(3); // Determinación de precio
    };

    //=========================================================
    //           Otras Entidades de Soporte en materials
    //=========================================================

    entity Categories : managed {
        key ID   : String(1);
            Name : localized String; // Nombre de la categoría
    };

    entity StockAvailability : managed {
        key ID          : Integer;
            Description : localized String;
            Product     : Association to Products;
    };

    entity Currencies : managed {
        key ID          : String(3);
            Description : localized String;
    };

    entity UnitOfMeasures : managed {
        key ID          : String(2);
            Description : localized String;
    };

    entity DimensionUnit : managed {
        key ID          : String(2);
            Description : localized String;
    };

    entity ProductReviews : cuid, managed {
        Name    : String;
        Rating  : Integer;
        Comment : String;
        Product : Association to Products; // Relación a producto reseñado
    };

    // Proyecciones (vistas CDS)
    entity SelProducts    as select from Products;
    entity ProjProducts   as projection on Products;

    entity ProjProducts01 as
        projection on SelProducts01 {
            Name,
            Description,
            Price,
        };
}

context Sales {

    entity Orders : cuid {
        Date     : Date; // Fecha de orden
        Customer : String; // Nombre o ID del cliente

        // Composición: relación fuerte a los ítems de la orden
        Item     : Composition of many OrdersItems
                       on Item.Order = $self;
    }

    entity OrdersItems : cuid {
        Order    : Association to Orders;
        Product  : Association to materials.Products;
        Quantity : Integer;
    }

    entity Suppliers : cuid, managed {
        Name    : LocalizedName; // Nombre del proveedor
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;

        // Relación a productos del proveedor
        Product : Association to many materials.Products
                      on Product.Supplier = $self;
    };

    entity Months : managed {
        key ID               : String(2);
            Description      : localized String;
            ShortDescription : localized String(3);
    };

    entity SalesData : cuid, managed {
        DeliveryDate : DateTime;
        Revenue      : Decimal(16, 2);
        Product      : Association to materials.Products;
        Currency     : Association to materials.Currencies;
        DeliveryM    : Association to Months;
    };
}

// Entidad con campos virtuales (solo en memoria)
entity car : cuid, managed {
            Name        : String;
            // Campo virtual que puede ser enviado desde cliente
    virtual discount_01 : Decimal @Core.Computed: false;
            // Campo virtual solo de lectura
    virtual discount_02 : Decimal;
}

// Vista CDS simple sobre Products
entity SelProducts01 as
    select from materials.Products {
        Name,
        Description,
        Quantity,
        Price,
    };

// Vista CDS con join y agregación
entity SelProducts02 as
    select from materials.Products
    left join materials.ProductReviews
        on Products.Name = ProductReviews.Name
    {
        Rating,
        Products.Name,
        sum(Price) as TotalPrice
    }
    group by
        Rating,
        Products.Name
    order by
        Rating;

context reports {
    //=========================================================
    //                       Agrupaciones
    //=========================================================
    entity AvarageRating as
        select from famj.materials.ProductReviews {
            Product.ID  as ProductId,
            avg(Rating) as AvarageRating : Decimal(16, 2) //Casting Columna
        }
        group by
            Product.ID;


    //=========================================================
    //        Mixin Asociaciones no Administradas
    //=========================================================
    entity Products      as
        select from famj.materials.Products
        mixin {
            ToStockAvailability : Association to famj.materials.StockAvailability
                                      on ToStockAvailability.ID = $projection.StockAvailability;
            ToAverageRating     : Association to AvarageRating
                                      on ToAverageRating.ProductId = ID;
        }
        into {
            *,
            ToAverageRating.AvarageRating as Rating,
            case
                when
                    Quantity >= 8
                then
                    3
                when
                    Quantity > 0
                then
                    2
                else
                    1
            end                           as StockAvailability : Integer,
            ToStockAvailability
        }
}
