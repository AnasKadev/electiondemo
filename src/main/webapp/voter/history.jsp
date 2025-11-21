<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.voting.entities.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.hibernate.*" %>
<%@ page import="com.voting.util.HibernateUtil" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("user") == null || !"VOTER".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    User currentUser = (User) session.getAttribute("user");
    Session hibernateSession = HibernateUtil.getSessionFactory().openSession();

    // Get all user's votes
    List<Vote> userVotes = hibernateSession.createQuery(
        "FROM Vote v WHERE v.user.id = :userId ORDER BY v.voteDate DESC",
        Vote.class
    ).setParameter("userId", currentUser.getId()).list();

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Historique de Votes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #4f46e5;
            --secondary-color: #06b6d4;
            --success-color: #10b981;
            --dark-color: #1f2937;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .navbar-custom {
            background: white;
            padding: 1rem 0;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
        }

        .history-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 2rem 1rem;
        }

        .header-card {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            animation: slideDown 0.5s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .vote-card {
            background: white;
            border-radius: 15px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border-left: 5px solid var(--primary-color);
            animation: fadeIn 0.5s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateX(-30px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .vote-card:hover {
            transform: translateX(10px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
        }

        .vote-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }

        .election-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--dark-color);
            margin: 0;
        }

        .vote-badge {
            background: var(--success-color);
            color: white;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .vote-details {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }

        .detail-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #6b7280;
        }

        .detail-item i {
            color: var(--primary-color);
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .empty-state i {
            font-size: 5rem;
            color: #d1d5db;
            margin-bottom: 1rem;
        }

        .timeline {
            position: relative;
            padding-left: 2rem;
        }

        .timeline::before {
            content: '';
            position: absolute;
            left: 8px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #e5e7eb;
        }

        .timeline-item {
            position: relative;
            margin-bottom: 2rem;
        }

        .timeline-dot {
            position: absolute;
            left: -2rem;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: var(--success-color);
            border: 3px solid white;
            box-shadow: 0 0 0 3px var(--success-color);
        }
    </style>
</head>
<body>
    <nav class="navbar-custom">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center w-100">
                <h4 class="m-0"><i class="fas fa-vote-yea"></i> Système de Vote</h4>
                <div>
                    <span class="me-3"><i class="fas fa-user-circle"></i> <%= currentUser.getUsername() %></span>
                    <a href="dashboard.jsp" class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-home"></i> Tableau de bord
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="history-container">
        <div class="header-card">
            <h2>
                <i class="fas fa-history"></i>
                Historique de Votes
            </h2>
            <p class="text-muted mb-0">
                Consultez l'historique complet de vos participations aux élections
            </p>
            <div class="mt-3">
                <span class="badge bg-primary" style="font-size: 1rem; padding: 0.5rem 1rem;">
                    <i class="fas fa-chart-bar"></i> Total: <%= userVotes.size() %> votes
                </span>
            </div>
        </div>

        <% if(userVotes.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-inbox"></i>
                <h3>Aucun vote enregistré</h3>
                <p class="text-muted">Vous n'avez pas encore participé à une élection.</p>
                <a href="dashboard.jsp" class="btn btn-primary mt-3">
                    <i class="fas fa-vote-yea"></i> Participer à une élection
                </a>
            </div>
        <% } else { %>
            <div class="timeline">
                <% for(int i = 0; i < userVotes.size(); i++) {
                    Vote vote = userVotes.get(i);
                %>
                    <div class="timeline-item" style="animation-delay: <%= i * 0.1 %>s;">
                        <div class="timeline-dot"></div>
                        <div class="vote-card">
                            <div class="vote-header">
                                <h5 class="election-title">
                                    <i class="fas fa-award"></i>
                                    <%= vote.getElection().getTitle() %>
                                </h5>
                                <span class="vote-badge">
                                    <i class="fas fa-check-circle"></i> Voté
                                </span>
                            </div>

                            <p class="text-muted mb-3">
                                <%= vote.getElection().getDescription() %>
                            </p>

                            <div class="vote-details">
                                <div class="detail-item">
                                    <i class="fas fa-user"></i>
                                    <span><strong>Candidat:</strong> <%= vote.getCandidate().getName() %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-calendar"></i>
                                    <span><strong>Date du vote:</strong> <%= dateFormat.format(vote.getVoteDate()) %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-calendar-check"></i>
                                    <span><strong>Début élection:</strong> <%= dateFormat.format(vote.getElection().getStartDate()) %></span>
                                </div>
                                <div class="detail-item">
                                    <i class="fas fa-calendar-times"></i>
                                    <span><strong>Fin élection:</strong> <%= dateFormat.format(vote.getElection().getEndDate()) %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>

        <div class="text-center mt-4">
            <a href="dashboard.jsp" class="btn btn-lg btn-primary">
                <i class="fas fa-arrow-left"></i> Retour au Tableau de Bord
            </a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<% hibernateSession.close(); %>

