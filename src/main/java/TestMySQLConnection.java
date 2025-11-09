import java.sql.Connection;
import java.sql.DriverManager;

public class TestMySQLConnection {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/voting_system?createDatabaseIfNotExist=true",
                "root",
                "anas123"
            );
            System.out.println("Database connection successful!");
            conn.close();
        } catch (Exception e) {
            System.err.println("Error connecting to database:");
            e.printStackTrace();
        }
    }
}
