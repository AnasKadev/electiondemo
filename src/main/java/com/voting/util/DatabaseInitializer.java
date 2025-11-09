package com.voting.util;

import com.voting.entities.User;
import org.hibernate.Session;
import org.hibernate.Transaction;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class DatabaseInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        initializeDatabase();
    }

    private void initializeDatabase() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();

            // Vérifier si l'administrateur existe déjà
            Long adminCount = session.createQuery("SELECT COUNT(u) FROM User u WHERE u.role = :role", Long.class)
                    .setParameter("role", "ADMIN")
                    .uniqueResult();

            if (adminCount == 0) {
                // Créer l'administrateur par défaut
                User admin = new User();
                admin.setUsername("admin");
                admin.setPassword("admin123");
                admin.setRole("ADMIN");

                session.persist(admin);

                // Créer un utilisateur votant de test
                User voter = new User();
                voter.setUsername("voter");
                voter.setPassword("voter123");
                voter.setRole("VOTER");

                session.persist(voter);

                tx.commit();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // Nettoyage si nécessaire
    }
}
