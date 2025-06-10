//Comandos
//cds db/schema.cds -2 sql > DDL_Script

namespace com.famj;

//Definir tipos Personalizados
define type Name : String(20); //Tipo Personalizado

//Tipo Enumeraciones
// type Gender      : String enum {
//     male;
//     female;
// };

// entity Order {
//     clientGender : Gender;
//     status       : Integer enum {
//         submitted = 1;
//         fulfiller = 2;
//         shipped = 3;
//         cancel = -1;
//     };
//     priority     : String @assert.range enum {
//         high;
//         medium;
//         low;
//     }
// }


//Tipo Referencia
type Dec         : Decimal(16, 2);

//Tipos Estructurados
define type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

// //Tipo Matriz (Tabla interna)
// type EmailAddress_01 : array of {
//     kind  : String;
//     Email : String;
// };

// type EmailAddress_02 : many {
//     kind  : String;
//     Email : String;
// };

// //Definir entidad
// entity Emails {
//     Email_01 : EmailAddress_01;
//     Email_02 : EmailAddress_02;
// }


//Abstracta : No se representa a base de Datos
entity Products {
    key ID               : UUID;
        Name             : String; //default "NoName";  // Valor Predeterminado
        Description      : String not null; //Restricción
        ImageUrl         : String;
        ReleaseDate      : DateTime default $now; // Valor Predeterminado
        DiscontinuedDate : DateTime;
        Price            : Dec;
        Height           : type of Price; // Tipo de Referencia
        Width            : Decimal(16, 2);
        Depth            : Decimal(16, 2);
        Quantity         : Decimal(16, 2);
        //*********************************************************************************************************************************************************************************************************
        // Asociaciones No Administradas
        // Supplier_Id      : UUID;
        // ToSupplier       : Association to one Suppliers
        //                        on ToSupplier.ID = Supplier_Id; //No administrada
        // UnitOfMeasure_Id : String(2);
        // ToUnitOfMeasure  : Association to UnitOfMeasures
        //                        on ToUnitOfMeasure.ID = UnitOfMeasure_Id;
        //*********************************************************************************************************************************************************************************************************
        //Asociaciones Administradas
        Supplier         : Association to one Suppliers; //Asociación Administrada
        UnitOfMeasure    : Association to UnitOfMeasures; //Asociación Administrada
        Currency         : Association to Currencies; //Asociación Administrada
        DimensionUnit    : Association to DimensionUnit; //Asociación Administrada
        Category         : Association to Categories; //Asociación Administrada
        //*********************************************************************************************************************************************************************************************************
        //Asociaciones Many
        SalesData        : Association to many SalesData
                               on SalesData.Product = $self;
        Reviews          : Association to many ProductReviews
                               on Reviews.Product = $self;


};

entity Suppliers {

    key ID      : UUID;
        Name    : Products : Name; // Tipo de Referencia
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to many Products
                      on Product.Supplier = $self;
};

// entity Suppliers_01 {

//     key ID      : UUID;
//         Name    : String;
//         Address : Address;
//         Email   : String;
//         Phone   : String;
//         Fax     : String;
// };

// entity Suppliers_02 {

//     key ID      : UUID;
//         Name    : String;
//         Address : {
//             Street     : String;
//             City       : String;
//             State      : String(2);
//             PostalCode : String(5);
//             Country    : String(3);
//         };
//         Email   : String;
//         Phone   : String;
//         Fax     : String;
// };


entity Categories {
    key ID   : String(1);
        Name : String;
};

entity StockAvailability {
    key ID          : Integer;
        Description : String;
}

entity Currencies {
    key ID          : String(3);
        Description : String;
};

entity UnitOfMeasures {
    key ID          : String(2);
        Description : String;
}

entity DimensionUnit {

    key ID          : String(2);
        Description : String;
};

entity Months {
    key ID               : String(2);
        Description      : String;
        ShortDescription : String(3);
};

entity ProductReviews {
    key ID      : UUID;
        Name    : String;
        Rating  : Integer;
        Comment : String;
        Product : Association to Products; //Asociación Administrada
};

entity SalesData {
    key ID           : UUID;
        DeliveryDate : DateTime;
        Revenue      : Decimal(16, 2);
        Product      : Association to Products; //Asociación Administrada
        Currency     : Association to Currencies; //Asociación Administrada
        DeliveryM    : Association to Months; //Asociación Administrada
}

//Campos Virtuales
entity car {
    key     ID          : UUID;
            Name        : String;
    virtual discount_01 : Decimal @Core.Computed: false; //Permite enviar valores desde el cliente
    virtual discount_02 : Decimal;
}

//*********************************************************************************************************************************************************************************************************
//                                                    Entidades Select
//*********************************************************************************************************************************************************************************************************

entity SelProducts    as select from Products;

entity SelProducts01  as
    select from Products {
        Name,
        Description,
        Quantity,
        Price,
    };

//Inner
entity SelProducts02  as
    select from Products
    left join ProductReviews
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

//*********************************************************************************************************************************************************************************************************
//                                                    Vista de Projection
//*********************************************************************************************************************************************************************************************************

entity ProjProducts   as projection on Products;

entity ProjProducts01 as
    projection on SelProducts01 {
        Name,
        Description,
        Price,
    };

//*********************************************************************************************************************************************************************************************************
//                                                    Entity with Parameters
//*********************************************************************************************************************************************************************************************************

// entity ParamProducts(pName : String) as
//     select from Products {
//         Name,
//         Description,
//         Quantity,
//         Price
//     }
//     where Name = :pName;

// //Parametro en Entidad Projection

// entity ParamProjProducts(pName : String) as projection on Products where Name = :pName;


//*********************************************************************************************************************************************************************************************************
//                                                    Entity de Ampliación
//*********************************************************************************************************************************************************************************************************

//Amplia tabla Products
extend Products with {
    PriceCondition     : String(2);
    PriceDetermination : String(3);
}

//*********************************************************************************************************************************************************************************************************
//Asociaciones Many to Many
//*********************************************************************************************************************************************************************************************************

entity Course {
    key ID      : UUID;
        Student : Association to many StudentCourse
                      on Student.Course = $self;
}

entity Student {
    key ID     : UUID;
        Course : Association to many StudentCourse
                     on Course.Student = $self;
}

entity StudentCourse {
    key ID      : UUID;
        Student : Association to Student;
        Course  : Association to Course;

}

//*********************************************************************************************************************************************************************************************************
//Composición
//*********************************************************************************************************************************************************************************************************

entity Orders {
    key ID       : UUID;
        Date     : Date;
        Customer : String;

        //Composition
        Item     : Composition of many OrdersItems
                       on Item.Order = $self;
// Item     : Composition of many {
//                key Position : String(3);
//                    Order    : Association to Orders;
//                    Product  : Association to Products;
//                    Quantity : Integer;
//            }
}

entity OrdersItems {
    key ID       : UUID;
        Order    : Association to Orders;
        Product  : Association to Products;
        Quantity : Integer;

}
