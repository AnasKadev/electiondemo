package com.voting.servlets;

import com.voting.entities.User;
import com.voting.util.HibernateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.exception.ConstraintViolationException;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Les mots de passe ne correspondent pas");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();

            // Vérifier si le nom d'utilisateur existe déjà
            Long userCount = session.createQuery(
                    "SELECT COUNT(u) FROM User u WHERE u.username = :username",
                    Long.class)
                    .setParameter("username", username)
                    .uniqueResult();

            if (userCount > 0) {
                request.setAttribute("error", "Ce nom d'utilisateur est déjà pris");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // Créer le nouveau compte votant
            User user = new User();
            user.setUsername(username);
            user.setPassword(password);
            user.setRole("VOTER");

            session.persist(user);
            tx.commit();

            request.setAttribute("message", "Inscription réussie ! Vous pouvez maintenant vous connecter.");
            response.sendRedirect("login.jsp");

        } catch (ConstraintViolationException e) {
            request.setAttribute("error", "Ce nom d'utilisateur est déjà pris");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Une erreur est survenue lors de l'inscription");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
