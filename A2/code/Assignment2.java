import java.sql.*;
import java.util.Date;
import java.util.Arrays;
import java.util.List;

public class Assignment2 {

   // A connection to the database
   Connection connection;

   // Can use if you wish: seat letters
   List<String> seatLetters = Arrays.asList("A", "B", "C", "D", "E", "F");

   Assignment2() throws SQLException {
      try {
         Class.forName("org.postgresql.Driver");
      } catch (ClassNotFoundException e) {
         e.printStackTrace();
      }
   }

   


  /**
   * Connects and sets the search path.
   *
   * Establishes a connection to be used for this session, assigning it to
   * the instance variable 'connection'.  In addition, sets the search
   * path to 'air_travel, public'.
   *
   * @param  url       the url for the database
   * @param  username  the username to connect to the database
   * @param  password  the password to connect to the database
   * @return           true if connecting is successful, false otherwise
   */
   public boolean connectDB(String URL, String username, String password) {
	// Implement this method!
	try{
        	connection = DriverManager.getConnection(URL, username, password);
		String queryString = "set search_path to air_travel,public";
        	PreparedStatement pStatement = connection.prepareStatement(queryString);
        	pStatement.executeUpdate();
		return true;
	} catch (SQLException se){
		//throw new SQLException("Connection failed: " + se);
                System.err.println("SQL Exception." + "<Message>: " + se.getMessage());	
        }
	return false;
      
   }

  /**
   * Closes the database connection.
   *
   * @return true if the closing was successful, false otherwise
   */
   public boolean disconnectDB() {
      // Implement this method!
	try{
		connection.close();
		return true;
	}catch(SQLException se){
		System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
	}
	return false;
   }
   
   /* ======================= Airline-related methods ======================= */

   /**
    * Attempts to book a flight for a passenger in a particular seat class. 
    * Does so by inserting a row into the Booking table.
    *
    * Read handout for information on how seats are booked.
    * Returns false if seat can't be booked, or if passenger or flight cannot be found.
    *
    * 
    * @param  passID     id of the passenger
    * @param  flightID   id of the flight
    * @param  seatClass  the class of the seat (economy, business, or first) 
    * @return            true if the booking was successful, false otherwise. 
    */
   public boolean bookSeat(int passID, int flightID, String seatClass) {
      // Implement this method!
	try{

	PreparedStatement ps = connection.prepareStatement(
        "SELECT flight.id, plane.capacity_economy as capacity_economy, plane.capacity_business as capacity_business, plane.capacity_first as capacity_first " +
        "FROM flight, plane " +
	"WHERE flight.plane = plane.tail_number" +
	"	and flight.id = ?");

	ps.setInt(1, flightID);
        ResultSet flight_capacity = ps.executeQuery();
	
	PreparedStatement flight_price = connection.prepareStatement("SELECT * FROM price WHERE flight_id = ?");
        flight_price.setInt(1, flightID);
        ResultSet rs = flight_price.executeQuery();
	
	PreparedStatement ps1 = connection.prepareStatement(
        "SELECT count(*) " +
        "FROM booking " +
	"WHERE booking.flight_id = ? and seat_class = ?::seat_class ");
	ps1.setInt(1, flightID);
	ps1.setString(2, seatClass);

	ResultSet already_booked = ps1.executeQuery();

	while(rs.next() && flight_capacity.next() && already_booked.next()){
	int price = rs.getInt(seatClass);
	

	if(seatClass == "economy"){
		if(flight_capacity.getInt("capacity_economy") - already_booked.getInt("count") > -10){
			PreparedStatement pse = connection.prepareStatement(
        		"INSERT INTO booking " +
       			 "VALUES((SELECT MAX(id) FROM booking)+1, ?, ?, ?, ?, ?::seat_class, ?, ?)" );
			pse.setInt(1, passID);
			pse.setInt(2, flightID);
			pse.setTimestamp(3, getCurrentTimeStamp());
			pse.setInt(4, price);
			pse.setString(5, seatClass);
			
			if(flight_capacity.getInt("capacity_economy") - already_booked.getInt("count") > 0){
				int economy_start = flight_capacity.getInt("capacity_first")/6 + 1 + flight_capacity.getInt("capacity_business")/6 + 1 + 1;		
				int max_row = economy_start + already_booked.getInt("count")/6;
				int max_letter_num = already_booked.getInt("count") % 6;

				char max_letter = 'A';
				if(max_letter_num != 0){
					max_letter = (char)(max_letter + max_letter_num);
				}
				if(max_letter_num == 0){
					max_row = max_row + 1;
				}
	
				pse.setInt(6, max_row);
				pse.setString(7, max_letter+" ");
				pse.setString(7, String.valueOf(max_letter));
		
			}else{
				pse.setNull(6, Types.NULL);
                   	        pse.setNull(7, Types.NULL);
			}
			
			pse.executeUpdate();
			
			return true;

		}return false;
	} 
	if(seatClass == "business"){
		if(flight_capacity.getInt("capacity_business") - already_booked.getInt("count")> 0){
			PreparedStatement psb = connection.prepareStatement(
        		"INSERT INTO booking " +
       			 "VALUES((SELECT MAX(id) FROM booking)+1, ?, ?, ?, ?, ?::seat_class, ?, ?)" );
			psb.setInt(1, passID);
			psb.setInt(2, flightID);
			psb.setTimestamp(3, getCurrentTimeStamp());
			psb.setInt(4, price);
			psb.setString(5, seatClass);
			int business_start = flight_capacity.getInt("capacity_first")/6 + 1 + 1;		
			int max_row = business_start + already_booked.getInt("count")/6;
			
			int max_letter_num = already_booked.getInt("count") % 6;

			char max_letter = 'A';
			if(max_letter_num != 0){
				max_letter = (char)(max_letter + max_letter_num);
			}
			if(max_letter_num == 0){
				max_row = max_row + 1;
			}

			psb.setInt(6, max_row);
			psb.setString(7, max_letter+" ");
			psb.setString(7, String.valueOf(max_letter));
			
			psb.executeUpdate();
			return true;

		}return false;
	} 
	if(seatClass == "first"){

		if(flight_capacity.getInt("capacity_first") - already_booked.getInt("count")> 0){
			
			PreparedStatement psf = connection.prepareStatement(
        		"INSERT INTO booking " +
       			 "VALUES((SELECT MAX(id) FROM booking)+1, ?, ?, ?, ?, ?::seat_class, ?, ?)" );
			psf.setInt(1, passID);
			psf.setInt(2, flightID);
			psf.setTimestamp(3, getCurrentTimeStamp());
			psf.setInt(4, price);
			psf.setString(5, seatClass);
			int first_start = 1;		
			int max_row = first_start + already_booked.getInt("count")/6;
			
			int max_letter_num = already_booked.getInt("count") % 6;

			char max_letter = 'A';
			if(max_letter_num != 0){
				max_letter = (char)(max_letter + max_letter_num);
			}
			if(max_letter_num == 0){
				max_row = max_row + 1;
			}

			psf.setInt(6, max_row);
			psf.setString(7, max_letter+" ");
			psf.setString(7, String.valueOf(max_letter));
			
			psf.executeUpdate();
			
			return true;

		}
		
		return false;
		
	} 



	}
	} catch(SQLException se){
		System.err.println("SQL Exception." + "<Message>: " + se.getMessage());
		return false;
	}


      return false;
   
	}

   /**
    * Attempts to upgrade overbooked economy passengers to business class
    * or first class (in that order until each seat class is filled).
    * Does so by altering the database records for the bookings such that the
    * seat and seat_class are updated if an upgrade can be processed.
    *
    * Upgrades should happen in order of earliest booking timestamp first.
    *
    * If economy passengers left over without a seat (i.e. more than 10 overbooked passengers or not enough higher class seats), 
    * remove their bookings from the database.
    * 
    * @param  flightID  The flight to upgrade passengers in.
    * @return           the number of passengers upgraded, or -1 if an error occured.
    */
   public int upgrade(int flightID) {
try{
      // Implement this method!
	PreparedStatement psf = connection.prepareStatement(
        "SELECT flight_id, count(id), max(row) as max_row " +
        "FROM booking " +
	"WHERE flight_id = ? and seat_class = 'first' " +
	"Group By (flight_id)");
	psf.setInt(1, flightID);
	ResultSet booked_f = psf.executeQuery();

	PreparedStatement psb = connection.prepareStatement(
        "SELECT flight_id, count(id), max(row) as max_row  " +
        "FROM booking " +
	"WHERE flight_id = ? and seat_class = 'business' " +
	"Group By (flight_id)");
	psb.setInt(1, flightID);
	ResultSet booked_b = psb.executeQuery();

	PreparedStatement pse = connection.prepareStatement(
        "SELECT flight_id, count(id), max(row) as max_row  " +
        "FROM booking " +
	"WHERE flight_id = ? and seat_class = 'economy' " +
	"Group By (flight_id)");
	pse.setInt(1, flightID);
	ResultSet booked_e = pse.executeQuery();

	
	PreparedStatement psc = connection.prepareStatement(
        "SELECT flight.id, plane.capacity_economy as capacity_economy, plane.capacity_business as capacity_business, plane.capacity_first as capacity_first " +
        "FROM flight, plane " +
	"WHERE flight.plane = plane.tail_number" +
	"	and flight.id = ?");
	psc.setInt(1, flightID);
        ResultSet flight_capacity = psc.executeQuery();
	
	
	while(booked_f.next() && booked_b.next() && booked_e.next() && flight_capacity.next()){
		int max_upgrade_business = -booked_b.getInt("count")+flight_capacity.getInt("capacity_business");
		int max_upgrade_first = -booked_f.getInt("count")+flight_capacity.getInt("capacity_first");
		//int max_upgrade = max_upgrade_business + max_upgrade_first;
		int count_upgrade_business = 0;
		int count_upgrade_first = 0;
		if(booked_e.getInt("count")<=flight_capacity.getInt("capacity_economy")){
			return 0;		
		} else {
			PreparedStatement needmod = connection.prepareStatement(
			"SELECT id " +
			"FROM booking " +
			"WHERE flight_id = ? and seat_class = 'economy' and row is NULL and letter is NULL " +
			"Order by datetime");
			needmod.setInt(1, flightID);
			ResultSet booked_null = needmod.executeQuery();

			while(booked_null.next()){
				if(max_upgrade_business > 0){
					PreparedStatement modify = connection.prepareStatement(
					"update booking " +
					"set seat_class = 'business' and row = ? and letter = ? " +
					"WHERE booking.id = booked_null.id ");

					int max_row = booked_b.getInt("maxrow");
			
					int max_letter_num = booked_b.getInt("count") % 6;

					char max_letter = 'A';
					if(max_letter_num != 0){
						max_letter = (char)(max_letter + max_letter_num);
					}
					if(max_letter_num == 0){
						max_row = max_row + 1;
					}

					modify.setInt(1, max_row);
					modify.setString(2, max_letter+" ");
					modify.setString(2, String.valueOf(max_letter));
					
					modify.executeUpdate();	
					//max_upgrade--;
					max_upgrade_business--;	
					count_upgrade_business++;			
				
				} else if(max_upgrade_first > 0){
					PreparedStatement modify = connection.prepareStatement(
					"update booking " +
					"set seat_class = 'first' and row = ? and letter = ? " +
					"WHERE booking.id = booked_null.id ");

					int max_row = booked_f.getInt("maxrow");
			
					int max_letter_num = booked_f.getInt("count") % 6;

					char max_letter = 'A';
					if(max_letter_num != 0){
						max_letter = (char)(max_letter + max_letter_num);
					}
					if(max_letter_num == 0){
						max_row = max_row + 1;
					}

					modify.setInt(1, max_row);
					modify.setString(2, max_letter+" ");
					modify.setString(2, String.valueOf(max_letter));
					
					modify.executeUpdate();	
					//max_upgrade--;
					max_upgrade_first--;
					count_upgrade_first++;
					
				} else {
					PreparedStatement delete = connection.prepareStatement(
					"delete from booking " +
					"WHERE booking.id = ? ");
					delete.setInt(1, booked_null.getInt("id"));
					delete.executeUpdate();				
				}
			}
			return count_upgrade_business + count_upgrade_first;
		}
	}





      } catch(SQLException se){
		
		//System.err.println("SQL Exception." + "<Message>: " + se.printStackTrace());
		se.printStackTrace();
		return -1;
      }



      return -1;
   }


   /* ----------------------- Helper functions below  ------------------------- */

    // A helpful function for adding a timestamp to new bookings.
    // Example of setting a timestamp in a PreparedStatement:
    // ps.setTimestamp(1, getCurrentTimeStamp());

    /**
    * Returns a SQL Timestamp object of the current time.
    * 
    * @return           Timestamp of current time.
    */
   private java.sql.Timestamp getCurrentTimeStamp() {
      java.util.Date now = new java.util.Date();
      return new java.sql.Timestamp(now.getTime());
   }

   // Add more helper functions below if desired.


  
  /* ----------------------- Main method below  ------------------------- */

   public static void main(String[] args){
      // You can put testing code in here. It will not affect our autotester.
    
	try{
		Assignment2 a2 = new Assignment2();
		boolean con = a2.connectDB("jdbc:postgresql://localhost:5432/csc343h-zhengm22", "zhengm22", "");
		boolean b= a2.bookSeat(1,5,"economy");
                //b= a2.bookSeat(1,10,"business");
                //for(int i =0; i<150; i++){
                  //b = a2.bookSeat(1,5,"first");
                  //b = a2.bookSeat(1,5,"business");
                  //b = a2.bookSeat(1,5,"economy");
              //}
                
		//int upgrade_num = a2.upgrade(5);
		//System.out.println(upgrade_num);
	}catch(SQLException se){
		//System.err.println("SQL Exception." + "<Message>: " + se.printStackTrace());
		 se.printStackTrace();	
	}
	

   }

}
