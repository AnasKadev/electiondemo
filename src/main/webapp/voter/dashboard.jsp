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

    Session hibernateSession = HibernateUtil.getSessionFactory().openSession();
    List<Election> activeElections = hibernateSession.createQuery(
        "  FROM Election WHERE startDate <= CURRENT_DATE AND endDate >= CURRENT_DATE",
        Election.class
    ).list();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Voter Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h2>Tableau de bord électeur</h2>

        <div class="row mt-4">
            <div class="col-md-12">
                <h3>Élections actives</h3>
                <% if(activeElections.isEmpty()) { %>
                    <p>Aucune élection active en ce moment.</p>
                <% } else { %>
                    <div class="row">
                        <% for(Election election : activeElections) { %>
                            <div class="col-md-6 mb-4">
                                <div class="card">
                                    <div class="card-body">
                                        <h5 class="card-title"><%= election.getTitle() %></h5>
                                        <p class="card-text"><%= election.getDescription() %></p>
                                        <a href="vote.jsp?electionId=<%= election.getId() %>"
                                           class="btn btn-primary">Voter</a>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>
        </div>

        <div class="mt-3">
            <a href="../logout" class="btn btn-secondary">Déconnexion</a>
        </div>
    </div>
</body>
</html>
<% hibernateSession.close(); %>

