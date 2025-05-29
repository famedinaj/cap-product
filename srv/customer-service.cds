using {com.famj as famj} from '../db/schema';

service CustomerService {
   entity CustomerSrv as projection on famj.Customer;
}
 
 