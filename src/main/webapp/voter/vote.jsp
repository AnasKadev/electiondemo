<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.voting.entities.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.hibernate.*" %>
<%@ page import="com.voting.util.HibernateUtil" %>
<%
    if (session.getAttribute("user") == null || !"VOTER".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Long electionId = Long.parseLong(request.getParameter("electionId"));
    Session hibernateSession = HibernateUtil.getSessionFactory().openSession();
    Election election = hibernateSession.get(Election.class, electionId);
    List<Candidate> candidates = hibernateSession.createQuery(
        "FROM Candidate WHERE election.id = :electionId",
        Candidate.class
    ).setParameter("electionId", electionId)
    .list();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Voter - <%= election.getTitle() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h2><%= election.getTitle() %></h2>
        <p><%= election.getDescription() %></p>

        <% if(request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="../vote" method="post">
            <input type="hidden" name="electionId" value="<%= election.getId() %>">

            <div class="row mt-4">
                <% for(Candidate candidate : candidates) { %>
                    <div class="col-md-6 mb-3">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title"><%= candidate.getName() %></h5>
                                <p class="card-text"><%= candidate.getDescription() %></p>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio"
                                           name="candidateId" value="<%= candidate.getId() %>"
                                           id="candidate<%= candidate.getId() %>" required>
                                    <label class="form-check-label" for="candidate<%= candidate.getId() %>">
                                        Voter pour ce candidat
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>

            <div class="mt-3">
                <button type="submit" class="btn btn-primary">Confirmer le vote</button>
                <a href="dashboard.jsp" class="btn btn-secondary">Retour</a>
            </div>
        </form>
    </div>
</body>
</html>
<% hibernateSession.close(); %>

