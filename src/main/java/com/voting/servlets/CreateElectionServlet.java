package com.voting.servlets;

import com.voting.entities.Candidate;
import com.voting.entities.Election;
import com.voting.entities.User;
import com.voting.util.HibernateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/createElection")
public class CreateElectionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = (User) request.getSession().getAttribute("user");
        if (user == null || !"ADMIN".equals(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String[] candidateNames = request.getParameterValues("candidateNames[]");
        String[] candidateDescriptions = request.getParameterValues("candidateDescriptions[]");

        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date startDate = dateFormat.parse(startDateStr);
            Date endDate = dateFormat.parse(endDateStr);

            Election election = new Election();
            election.setTitle(title);
            election.setDescription(description);
            election.setStartDate(startDate);
            election.setEndDate(endDate);

            Set<Candidate> candidates = new HashSet<>();
            if (candidateNames != null) {
                for (int i = 0; i < candidateNames.length; i++) {
                    if (candidateNames[i] != null && !candidateNames[i].trim().isEmpty()) {
                        Candidate candidate = new Candidate();
                        candidate.setName(candidateNames[i].trim());
                        candidate.setDescription(candidateDescriptions[i].trim());
                        candidate.setElection(election);
                        candidates.add(candidate);
                    }
                }
            }
            election.setCandidates(candidates);

            try (Session session = HibernateUtil.getSessionFactory().openSession()) {
                Transaction tx = session.beginTransaction();
                session.persist(election);
                tx.commit();
            }

            response.sendRedirect("admin/dashboard.jsp");

        } catch (ParseException e) {
            request.setAttribute("error", "Format de date invalide");
            request.getRequestDispatcher("admin/createElection.jsp").forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Erreur lors de la création de l'élection: " + e.getMessage());
            request.getRequestDispatcher("admin/createElection.jsp").forward(request, response);
        }
    }
}
