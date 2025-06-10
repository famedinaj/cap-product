using {com.famj as famj} from '../db/schema';

service CatalogService {
   entity Products as projection on famj.Products;
   entity Suppliers as projection on famj.Suppliers;
   entity UnitOfMeasures as projection on famj.UnitOfMeasures;
   entity Currency as projection on famj.Currencies;
   entity DimensionUnit as projection on famj.DimensionUnit;
   entity Category as projection on famj.Categories;
   entity SalesData as projection on famj.SalesData;
   entity Reviews as projection on famj.ProductReviews;


   entity Order as projection on famj.Orders;
   entity OrderItem as projection on famj.OrdersItems;
   entity car as projection on famj.car;
} 
 
 