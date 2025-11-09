package com.voting.servlets;

import com.voting.entities.Election;
import com.voting.entities.User;
import com.voting.entities.Vote;
import com.voting.entities.Candidate;
import com.voting.util.HibernateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;
import java.io.IOException;

@WebServlet("/admin/deleteElection")
public class DeleteElection extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");

        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendRedirect("../login.jsp");
            return;
        }

        try {
            Long electionId = Long.parseLong(idParam);

            try (Session session = HibernateUtil.getSessionFactory().openSession()) {
                Transaction tx = session.beginTransaction();
                try {
                    Election election = session.get(Election.class, electionId);
                    if (election != null) {
                        // 1. Supprimer d'abord tous les votes associés à cette élection
                        session.createQuery("DELETE FROM Vote v WHERE v.election.id = :electionId")
                               .setParameter("electionId", electionId)
                               .executeUpdate();

                        // 2. Supprimer tous les candidats associés à cette élection
                        session.createQuery("DELETE FROM Candidate c WHERE c.election.id = :electionId")
                               .setParameter("electionId", electionId)
                               .executeUpdate();

                        // 3. Finalement, supprimer l'élection
                        session.remove(election);

                        tx.commit();
                        request.getSession().setAttribute("message", "Élection supprimée avec succès");
                    } else {
                        request.getSession().setAttribute("error", "Élection non trouvée");
                    }
                } catch (Exception e) {
                    if (tx != null && tx.isActive()) {
                        tx.rollback();
                    }
                    throw e;
                }
            } catch (Exception e) {
                request.getSession().setAttribute("error", "Erreur lors de la suppression : " + e.getMessage());
            }
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("error", "ID d'élection invalide");
        }

        response.sendRedirect("dashboard.jsp");
    }
}
