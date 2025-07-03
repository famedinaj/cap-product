namespace com.training;
//Comandos
//cds db/schema.cds -2 sql > DDL_Script

//Aspectos Comunes
using {
    cuid,
    managed,
    Country,
} from '@sap/cds/common';

entity Orders {
    key ClientEmail : String(65);
        FirstName   : String(30);
        LastName    : String(30);
        CreatedOn   : Date;
        Reviewed    : Boolean;
        Approved    : Boolean;
        Country     : Country;
}


// Tipo enumeraciones

// type Gender : String enum {
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
//Asociaciones Many to Many
//*********************************************************************************************************************************************************************************************************

entity Course : cuid, managed {
    Student : Association to many StudentCourse
                  on Student.Course = $self;
}

entity Student : cuid, managed {
    Course : Association to many StudentCourse
                 on Course.Student = $self;
}

entity StudentCourse : cuid, managed {
    Student : Association to Student;
    Course  : Association to Course;
}
