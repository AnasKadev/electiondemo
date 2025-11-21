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

    // Get active elections
    List<Election> activeElections = hibernateSession.createQuery(
        "FROM Election WHERE startDate <= CURRENT_DATE AND endDate >= CURRENT_DATE",
        Election.class
    ).list();

    // Get upcoming elections
    List<Election> upcomingElections = hibernateSession.createQuery(
        "FROM Election WHERE startDate > CURRENT_DATE",
        Election.class
    ).list();

    // Get past elections
    List<Election> pastElections = hibernateSession.createQuery(
        "FROM Election WHERE endDate < CURRENT_DATE ORDER BY endDate DESC",
        Election.class
    ).setMaxResults(5).list();

    // Get user's vote history
    List<Vote> userVotes = hibernateSession.createQuery(
        "FROM Vote v WHERE v.user.id = :userId ORDER BY v.voteDate DESC",
        Vote.class
    ).setParameter("userId", currentUser.getId()).setMaxResults(5).list();

    // Check which elections user has voted in
    Set<Long> votedElectionIds = new HashSet<>();
    for (Vote vote : userVotes) {
        votedElectionIds.add(vote.getElection().getId());
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord Électeur</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #4f46e5;
            --secondary-color: #06b6d4;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
            --dark-color: #1f2937;
            --light-bg: #f9fafb;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .dashboard-container {
            padding: 2rem 0;
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

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .welcome-text {
            color: var(--dark-color);
            margin: 0;
        }

        .stats-row {
            display: flex;
            gap: 1rem;
            margin-top: 1.5rem;
        }

        .stat-card {
            flex: 1;
            padding: 1.5rem;
            border-radius: 15px;
            text-align: center;
            color: white;
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-card.active {
            background: linear-gradient(135deg, var(--success-color), #059669);
        }

        .stat-card.upcoming {
            background: linear-gradient(135deg, var(--warning-color), #d97706);
        }

        .stat-card.voted {
            background: linear-gradient(135deg, var(--primary-color), #4338ca);
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: bold;
            margin: 0;
        }

        .stat-label {
            font-size: 0.9rem;
            opacity: 0.9;
            margin-top: 0.5rem;
        }

        .section-card {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            animation: fadeInUp 0.6s ease-out;
        }

        .section-title {
            color: var(--dark-color);
            font-weight: 600;
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .election-card {
            border: none;
            border-radius: 15px;
            overflow: hidden;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            height: 100%;
        }

        .election-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
        }

        .election-card-header {
            padding: 1.5rem;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            position: relative;
        }

        .election-badge {
            position: absolute;
            top: 1rem;
            right: 1rem;
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            background: rgba(255, 255, 255, 0.3);
            backdrop-filter: blur(10px);
        }

        .voted-badge {
            background: var(--success-color);
            color: white;
        }

        .election-title {
            font-size: 1.3rem;
            font-weight: 600;
            margin: 0;
        }

        .election-card-body {
            padding: 1.5rem;
        }

        .election-info {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 0.8rem;
            color: #6b7280;
            font-size: 0.9rem;
        }

        .election-info i {
            color: var(--primary-color);
        }

        .vote-button {
            width: 100%;
            padding: 0.8rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
        }

        .vote-button:hover {
            transform: scale(1.05);
            box-shadow: 0 10px 25px rgba(79, 70, 229, 0.3);
        }

        .vote-button:disabled {
            background: #d1d5db;
            cursor: not-allowed;
            transform: none;
        }

        .history-item {
            padding: 1rem;
            border-left: 4px solid var(--primary-color);
            background: var(--light-bg);
            border-radius: 0 10px 10px 0;
            margin-bottom: 1rem;
            transition: all 0.3s ease;
        }

        .history-item:hover {
            background: #f3f4f6;
            transform: translateX(5px);
        }

        .history-title {
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 0.3rem;
        }

        .history-details {
            font-size: 0.85rem;
            color: #6b7280;
        }

        .navbar-custom {
            background: white;
            padding: 1rem 0;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
        }

        .search-box {
            position: relative;
            margin-bottom: 1.5rem;
        }

        .search-box input {
            width: 100%;
            padding: 0.8rem 1rem 0.8rem 2.5rem;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        .search-box input:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }

        .search-box i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
        }

        .empty-state {
            text-align: center;
            padding: 3rem 1rem;
            color: #9ca3af;
        }

        .empty-state i {
            font-size: 4rem;
            margin-bottom: 1rem;
        }

        .countdown {
            font-weight: 600;
            color: var(--warning-color);
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
                    <a href="../logout" class="btn btn-outline-danger btn-sm">
                        <i class="fas fa-sign-out-alt"></i> Déconnexion
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container dashboard-container">
        <!-- Welcome Header -->
        <div class="header-card">
            <h2 class="welcome-text">
                <i class="fas fa-hand-wave" style="color: #fbbf24;"></i>
                Bienvenue, <%= currentUser.getUsername() %>!
            </h2>
            <p class="text-muted mb-0">Voici un aperçu de vos activités de vote</p>

            <div class="stats-row">
                <div class="stat-card active">
                    <p class="stat-number"><%= activeElections.size() %></p>
                    <p class="stat-label"><i class="fas fa-bolt"></i> Élections Actives</p>
                </div>
                <div class="stat-card upcoming">
                    <p class="stat-number"><%= upcomingElections.size() %></p>
                    <p class="stat-label"><i class="fas fa-clock"></i> À Venir</p>
                </div>
                <div class="stat-card voted">
                    <p class="stat-number"><%= userVotes.size() %></p>
                    <p class="stat-label"><i class="fas fa-check-circle"></i> Votes Effectués</p>
                </div>
            </div>
        </div>

        <!-- Active Elections -->
        <div class="section-card">
            <h3 class="section-title">
                <i class="fas fa-fire" style="color: var(--danger-color);"></i>
                Élections Actives
            </h3>

            <% if(activeElections.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    <p>Aucune élection active en ce moment.</p>
                    <p class="text-muted">Revenez plus tard pour participer aux votes!</p>
                </div>
            <% } else { %>
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="searchElections" placeholder="Rechercher une élection..."
                           onkeyup="filterElections()">
                </div>

                <div class="row" id="electionsContainer">
                    <% for(Election election : activeElections) {
                        boolean hasVoted = votedElectionIds.contains(election.getId());
                        List<Candidate> candidates = hibernateSession.createQuery(
                            "FROM Candidate WHERE election.id = :electionId",
                            Candidate.class
                        ).setParameter("electionId", election.getId()).list();
                    %>
                        <div class="col-md-6 col-lg-4 mb-4 election-item"
                             data-title="<%= election.getTitle().toLowerCase() %>">
                            <div class="election-card">
                                <div class="election-card-header">
                                    <% if(hasVoted) { %>
                                        <span class="election-badge voted-badge">
                                            <i class="fas fa-check"></i> Voté
                                        </span>
                                    <% } else { %>
                                        <span class="election-badge">
                                            <i class="fas fa-exclamation"></i> En attente
                                        </span>
                                    <% } %>
                                    <h5 class="election-title"><%= election.getTitle() %></h5>
                                </div>
                                <div class="election-card-body">
                                    <p class="text-muted"><%= election.getDescription() %></p>

                                    <div class="election-info">
                                        <i class="fas fa-calendar-start"></i>
                                        <span>Début: <%= dateFormat.format(election.getStartDate()) %></span>
                                    </div>
                                    <div class="election-info">
                                        <i class="fas fa-calendar-end"></i>
                                        <span>Fin: <%= dateFormat.format(election.getEndDate()) %></span>
                                    </div>
                                    <div class="election-info">
                                        <i class="fas fa-users"></i>
                                        <span><%= candidates.size() %> Candidats</span>
                                    </div>

                                    <% if(hasVoted) { %>
                                        <button class="vote-button" disabled>
                                            <i class="fas fa-check-double"></i> Déjà Voté
                                        </button>
                                    <% } else { %>
                                        <a href="vote.jsp?electionId=<%= election.getId() %>"
                                           class="vote-button btn">
                                            <i class="fas fa-vote-yea"></i> Voter Maintenant
                                        </a>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>

        <!-- Upcoming Elections -->
        <% if(!upcomingElections.isEmpty()) { %>
        <div class="section-card">
            <h3 class="section-title">
                <i class="fas fa-calendar-plus" style="color: var(--warning-color);"></i>
                Élections À Venir
            </h3>
            <div class="row">
                <% for(Election election : upcomingElections) { %>
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="election-card">
                            <div class="election-card-header" style="background: linear-gradient(135deg, #f59e0b, #d97706);">
                                <span class="election-badge">
                                    <i class="fas fa-hourglass-start"></i> Bientôt
                                </span>
                                <h5 class="election-title"><%= election.getTitle() %></h5>
                            </div>
                            <div class="election-card-body">
                                <p class="text-muted"><%= election.getDescription() %></p>

                                <div class="election-info">
                                    <i class="fas fa-calendar-start"></i>
                                    <span>Commence: <%= dateFormat.format(election.getStartDate()) %></span>
                                </div>
                                <div class="election-info">
                                    <i class="fas fa-calendar-end"></i>
                                    <span>Fin: <%= dateFormat.format(election.getEndDate()) %></span>
                                </div>

                                <button class="vote-button" style="background: #9ca3af;" disabled>
                                    <i class="fas fa-clock"></i> Pas Encore Commencée
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
        <% } %>

        <!-- Voting History -->
        <% if(!userVotes.isEmpty()) { %>
        <div class="section-card">
            <h3 class="section-title">
                <i class="fas fa-history" style="color: var(--primary-color);"></i>
                Historique de Votes Récents
            </h3>
            <% for(Vote vote : userVotes) { %>
                <div class="history-item">
                    <div class="history-title">
                        <i class="fas fa-check-circle" style="color: var(--success-color);"></i>
                        <%= vote.getElection().getTitle() %>
                    </div>
                    <div class="history-details">
                        <i class="fas fa-user"></i> Candidat: <%= vote.getCandidate().getName() %>
                        <span class="ms-3">
                            <i class="fas fa-calendar"></i> <%= dateFormat.format(vote.getVoteDate()) %>
                        </span>
                    </div>
                </div>
            <% } %>
            <% if(userVotes.size() >= 5) { %>
                <a href="history.jsp" class="btn btn-outline-primary mt-2">
                    <i class="fas fa-list"></i> Voir tout l'historique
                </a>
            <% } %>
        </div>
        <% } %>

        <!-- Past Elections Info -->
        <% if(!pastElections.isEmpty()) { %>
        <div class="section-card">
            <h3 class="section-title">
                <i class="fas fa-archive" style="color: #6b7280;"></i>
                Élections Terminées
            </h3>
            <p class="text-muted">Consultez les résultats des élections passées</p>
            <div class="row">
                <% for(Election election : pastElections) { %>
                    <div class="col-md-6 mb-3">
                        <div class="history-item">
                            <div class="history-title"><%= election.getTitle() %></div>
                            <div class="history-details">
                                <i class="fas fa-calendar-check"></i>
                                Terminée le <%= dateFormat.format(election.getEndDate()) %>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function filterElections() {
            const searchTerm = document.getElementById('searchElections').value.toLowerCase();
            const elections = document.querySelectorAll('.election-item');

            elections.forEach(election => {
                const title = election.getAttribute('data-title');
                if (title.includes(searchTerm)) {
                    election.style.display = 'block';
                } else {
                    election.style.display = 'none';
                }
            });
        }

        // Add animation on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }
            });
        }, observerOptions);

        document.querySelectorAll('.election-card').forEach(card => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(30px)';
            card.style.transition = 'all 0.6s ease';
            observer.observe(card);
        });
    </script>
</body>
</html>
<% hibernateSession.close(); %>

