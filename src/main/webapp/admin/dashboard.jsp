<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.voting.entities.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.hibernate.*" %>
<%@ page import="com.voting.util.HibernateUtil" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Session hibernateSession = HibernateUtil.getSessionFactory().openSession();
    List<Election> elections = hibernateSession.createQuery("FROM Election", Election.class).list();

    Map<Long, Long> voterCounts = new HashMap<>();
    Map<Long, Map<Long, Long>> candidateVoteCounts = new HashMap<>();
    for (Election election : elections) {
        Long voterCount = hibernateSession.createQuery(
            "SELECT COUNT(DISTINCT v.user.id) FROM Vote v WHERE v.election.id = :electionId",
            Long.class)
            .setParameter("electionId", election.getId())
            .uniqueResult();
        voterCounts.put(election.getId(), voterCount);


        List<Candidate> candidates = hibernateSession.createQuery(
            "FROM Candidate c WHERE c.election.id = :electionId",
            Candidate.class)
            .setParameter("electionId", election.getId())
            .list();

        Map<Long, Long> votesPerCandidate = new HashMap<>();
        for (Candidate candidate : candidates) {
            Long voteCount = hibernateSession.createQuery(
                "SELECT COUNT(*) FROM Vote v WHERE v.candidate.id = :candidateId",
                Long.class)
                .setParameter("candidateId", candidate.getId())
                .uniqueResult();
            votesPerCandidate.put(candidate.getId(), voteCount);
        }
        candidateVoteCounts.put(election.getId(), votesPerCandidate);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h2>Tableau de bord administrateur</h2>

        <% if(session.getAttribute("message") != null) { %>
            <div class="alert alert-success">
                <%= session.getAttribute("message") %>
                <% session.removeAttribute("message"); %>
            </div>
        <% } %>
        <% if(session.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= session.getAttribute("error") %>
                <% session.removeAttribute("error"); %>
            </div>
        <% } %>

        <div class="row mt-4">
            <div class="col-md-12">
                <h3>Élections en cours</h3>
                <% for(Election election : elections) { %>
                    <div class="card mb-4">
                        <div class="card-header">
                            <h4><%= election.getTitle() %></h4>
                        </div>
                        <div class="card-body">
                            <p><strong>Description:</strong> <%= election.getDescription() %></p>
                            <p><strong>Date de début:</strong> <%= election.getStartDate() %></p>
                            <p><strong>Date de fin:</strong> <%= election.getEndDate() %></p>
                            <p><strong>Nombre total de votants:</strong> <%= voterCounts.get(election.getId()) %></p>

                            <h5 class="mt-3">Résultats par candidat:</h5>
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th>Candidat</th>
                                        <th>Nombre de votes</th>
                                        <th>Pourcentage</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                    List<Candidate> candidates = hibernateSession.createQuery(
                                        "FROM Candidate c WHERE c.election.id = :electionId",
                                        Candidate.class)
                                        .setParameter("electionId", election.getId())
                                        .list();

                                    Map<Long, Long> votesForCandidates = candidateVoteCounts.get(election.getId());
                                    long totalVotes = votesForCandidates.values().stream().mapToLong(Long::longValue).sum();

                                    for(Candidate candidate : candidates) {
                                        long votes = votesForCandidates.get(candidate.getId());
                                        double percentage = totalVotes > 0 ? (votes * 100.0 / totalVotes) : 0;
                                    %>
                                        <tr>
                                            <td><%= candidate.getName() %></td>
                                            <td><%= votes %></td>
                                            <td><%= String.format("%.2f%%", percentage) %></td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>

                            <div class="mt-3">
                                <a href="editElection.jsp?id=<%= election.getId() %>" class="btn btn-sm btn-primary">Éditer</a>
                                <a href="deleteElection?id=<%= election.getId() %>" class="btn btn-sm btn-danger"
                                   onclick="return confirm('Êtes-vous sûr de vouloir supprimer cette élection ?')">Supprimer</a>
                            </div>
                        </div>
                    </div>
                <% } %>
                <a href="createElection.jsp" class="btn btn-success">Créer une nouvelle élection</a>
            </div>
        </div>

        <div class="mt-3 mb-5">
            <a href="../logout" class="btn btn-secondary">Déconnexion</a>
        </div>
    </div>
</body>
</html>
<% hibernateSession.close(); %>
