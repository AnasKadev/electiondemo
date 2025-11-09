package com.voting.servlets;

import com.voting.entities.*;
import com.voting.util.HibernateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.io.IOException;
import java.util.Date;

@WebServlet("/vote")
public class VoteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"VOTER".equals(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        Long candidateId = Long.parseLong(request.getParameter("candidateId"));
        Long electionId = Long.parseLong(request.getParameter("electionId"));

        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();

            // Vérifier si l'utilisateur n'a pas déjà voté pour cette élection
            Long voteCount = session.createQuery(
                "SELECT COUNT(v) FROM Vote v WHERE v.user.id = :userId AND v.election.id = :electionId",
                Long.class)
                .setParameter("userId", user.getId())
                .setParameter("electionId", electionId)
                .uniqueResult();

            if (voteCount > 0) {
                request.setAttribute("error", "Vous avez déjà voté pour cette élection");
                request.getRequestDispatcher("voter/vote.jsp").forward(request, response);
                return;
            }

            Candidate candidate = session.get(Candidate.class, candidateId);
            Election election = session.get(Election.class, electionId);

            Vote vote = new Vote();
            vote.setUser(user);
            vote.setCandidate(candidate);
            vote.setElection(election);
            vote.setVoteDate(new Date());

            session.persist(vote);
            tx.commit();

            response.sendRedirect("voter/dashboard.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Une erreur est survenue lors du vote");
            request.getRequestDispatcher("voter/vote.jsp").forward(request, response);
        }
    }
}
