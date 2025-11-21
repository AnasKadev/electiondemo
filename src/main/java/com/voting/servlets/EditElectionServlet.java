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
import jakarta.servlet.http.HttpSession;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

@WebServlet("/admin/editElection")
public class EditElectionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession httpSession = request.getSession();
        User user = (User) httpSession.getAttribute("user");
        String role = (String) httpSession.getAttribute("role");

        if (user == null || !"ADMIN".equals(role)) {
            response.sendRedirect("../login.jsp");
            return;
        }

        String electionIdParam = request.getParameter("electionId");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String[] candidateIds = request.getParameterValues("candidateIds[]");
        String[] candidateNames = request.getParameterValues("candidateNames[]");

        if (electionIdParam == null || title == null || description == null ||
            startDateStr == null || endDateStr == null || candidateNames == null) {
            httpSession.setAttribute("error", "Tous les champs sont requis.");
            response.sendRedirect("editElection.jsp?id=" + electionIdParam);
            return;
        }

        if (candidateNames.length < 2) {
            httpSession.setAttribute("error", "Une élection doit avoir au moins 2 candidats.");
            response.sendRedirect("editElection.jsp?id=" + electionIdParam);
            return;
        }

        Session hibernateSession = null;
        Transaction transaction = null;

        try {
            Long electionId = Long.parseLong(electionIdParam);
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
            Date startDate = dateFormat.parse(startDateStr);
            Date endDate = dateFormat.parse(endDateStr);

            if (endDate.before(startDate)) {
                httpSession.setAttribute("error", "La date de fin doit être après la date de début.");
                response.sendRedirect("editElection.jsp?id=" + electionId);
                return;
            }

            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            transaction = hibernateSession.beginTransaction();

            // Get the election
            Election election = hibernateSession.get(Election.class, electionId);
            if (election == null) {
                httpSession.setAttribute("error", "Élection introuvable.");
                response.sendRedirect("dashboard.jsp");
                return;
            }

            // Update election details
            election.setTitle(title);
            election.setDescription(description);
            election.setStartDate(startDate);
            election.setEndDate(endDate);
            hibernateSession.merge(election);

            // Process candidates
            // Create a map of existing candidates
            Map<Long, Candidate> existingCandidates = new HashMap<>();
            List<Candidate> currentCandidates = hibernateSession.createQuery(
                "FROM Candidate c WHERE c.election.id = :electionId",
                Candidate.class)
                .setParameter("electionId", electionId)
                .list();

            for (Candidate candidate : currentCandidates) {
                existingCandidates.put(candidate.getId(), candidate);
            }

            // Track which candidates to keep
            Set<Long> candidatesToKeep = new HashSet<>();

            // Process submitted candidates
            for (int i = 0; i < candidateNames.length; i++) {
                String candidateName = candidateNames[i].trim();
                if (candidateName.isEmpty()) {
                    continue;
                }

                String candidateIdStr = candidateIds[i];

                if (candidateIdStr != null && !candidateIdStr.isEmpty()) {
                    // Update existing candidate
                    Long candidateId = Long.parseLong(candidateIdStr);
                    Candidate candidate = existingCandidates.get(candidateId);
                    if (candidate != null) {
                        candidate.setName(candidateName);
                        hibernateSession.merge(candidate);
                        candidatesToKeep.add(candidateId);
                    }
                } else {
                    // Create new candidate
                    Candidate newCandidate = new Candidate();
                    newCandidate.setName(candidateName);
                    newCandidate.setElection(election);
                    hibernateSession.persist(newCandidate);
                }
            }

            // Delete candidates that were removed
            for (Candidate candidate : currentCandidates) {
                if (!candidatesToKeep.contains(candidate.getId())) {
                    // Check if candidate has votes
                    Long voteCount = hibernateSession.createQuery(
                        "SELECT COUNT(*) FROM Vote v WHERE v.candidate.id = :candidateId",
                        Long.class)
                        .setParameter("candidateId", candidate.getId())
                        .uniqueResult();

                    if (voteCount > 0) {
                        transaction.rollback();
                        httpSession.setAttribute("error",
                            "Impossible de supprimer le candidat " + candidate.getName() +
                            " car il a déjà reçu des votes.");
                        response.sendRedirect("editElection.jsp?id=" + electionId);
                        return;
                    }
                    hibernateSession.remove(candidate);
                }
            }

            transaction.commit();
            httpSession.setAttribute("message", "Élection modifiée avec succès!");
            response.sendRedirect("dashboard.jsp");

        } catch (Exception e) {
            if (transaction != null) {
                transaction.rollback();
            }
            e.printStackTrace();
            httpSession.setAttribute("error", "Erreur lors de la modification de l'élection: " + e.getMessage());
            response.sendRedirect("editElection.jsp?id=" + electionIdParam);
        } finally {
            if (hibernateSession != null) {
                hibernateSession.close();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("dashboard.jsp");
    }
}

