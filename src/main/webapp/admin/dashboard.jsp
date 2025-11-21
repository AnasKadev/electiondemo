<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.voting.entities.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.hibernate.*" %>
<%@ page import="com.voting.util.HibernateUtil" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    User currentUser = (User) session.getAttribute("user");
    Session hibernateSession = HibernateUtil.getSessionFactory().openSession();
    List<Election> elections = hibernateSession.createQuery("FROM Election ORDER BY startDate DESC", Election.class).list();

    Map<Long, Long> voterCounts = new HashMap<>();
    Map<Long, Map<Long, Long>> candidateVoteCounts = new HashMap<>();
    Map<Long, List<Candidate>> electionCandidates = new HashMap<>();

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

        electionCandidates.put(election.getId(), candidates);

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

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de bord Administrateur</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <style>
        :root {
            --primary-color: #4f46e5;
            --secondary-color: #06b6d4;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --danger-color: #ef4444;
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

        .dashboard-container {
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

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        .stat-card {
            padding: 1.5rem;
            border-radius: 15px;
            color: white;
            position: relative;
            overflow: hidden;
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: rgba(255, 255, 255, 0.1);
            transform: rotate(45deg);
        }

        .stat-card.primary {
            background: linear-gradient(135deg, var(--primary-color), #4338ca);
        }

        .stat-card.success {
            background: linear-gradient(135deg, var(--success-color), #059669);
        }

        .stat-card.warning {
            background: linear-gradient(135deg, var(--warning-color), #d97706);
        }

        .stat-card.danger {
            background: linear-gradient(135deg, var(--danger-color), #dc2626);
        }

        .stat-icon {
            font-size: 2.5rem;
            opacity: 0.3;
            position: absolute;
            right: 1rem;
            top: 1rem;
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }

        .stat-label {
            font-size: 1rem;
            opacity: 0.9;
        }

        .election-card {
            background: white;
            border-radius: 20px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            animation: fadeIn 0.6s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .election-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 1.5rem;
            padding-bottom: 1rem;
            border-bottom: 2px solid #e5e7eb;
        }

        .election-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 0.5rem;
        }

        .election-badge {
            padding: 0.4rem 1rem;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .badge-active {
            background: #d1fae5;
            color: #065f46;
        }

        .badge-upcoming {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-ended {
            background: #fee2e2;
            color: #991b1b;
        }

        .election-info {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 1.5rem;
        }

        .info-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #6b7280;
        }

        .info-item i {
            color: var(--primary-color);
        }

        .chart-container {
            position: relative;
            height: 300px;
            margin: 1.5rem 0;
        }

        .table-custom {
            border-radius: 10px;
            overflow: hidden;
        }

        .table-custom thead {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
        }

        .table-custom tbody tr {
            transition: all 0.3s ease;
        }

        .table-custom tbody tr:hover {
            background: #f3f4f6;
            transform: scale(1.02);
        }

        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }

        .btn-icon {
            width: 35px;
            height: 35px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .btn-icon:hover {
            transform: scale(1.1);
        }

        .create-button {
            background: linear-gradient(135deg, var(--success-color), #059669);
            color: white;
            padding: 1rem 2rem;
            border-radius: 12px;
            font-weight: 600;
            border: none;
            transition: all 0.3s ease;
            font-size: 1.1rem;
        }

        .create-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(16, 185, 129, 0.3);
        }

        .progress-bar-custom {
            height: 25px;
            border-radius: 10px;
            font-weight: 600;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            color: #9ca3af;
        }

        .empty-state i {
            font-size: 5rem;
            margin-bottom: 1rem;
        }
    </style>
</head>
<body>
    <nav class="navbar-custom">
        <div class="container-fluid">
            <div class="d-flex justify-content-between align-items-center w-100">
                <h4 class="m-0"><i class="fas fa-chart-line"></i> Administration - Système de Vote</h4>
                <div>
                    <span class="me-3"><i class="fas fa-user-shield"></i> <%= currentUser.getUsername() %></span>
                    <a href="../logout" class="btn btn-outline-danger btn-sm">
                        <i class="fas fa-sign-out-alt"></i> Déconnexion
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container-fluid dashboard-container">
        <!-- Header with Stats -->
        <div class="header-card">
            <h2>
                <i class="fas fa-tachometer-alt"></i>
                Tableau de bord Administrateur
            </h2>
            <p class="text-muted mb-0">Vue d'ensemble des élections et statistiques</p>

            <div class="stats-grid">
                <div class="stat-card primary">
                    <i class="fas fa-poll stat-icon"></i>
                    <div class="stat-value"><%= elections.size() %></div>
                    <div class="stat-label"><i class="fas fa-chart-bar"></i> Total Élections</div>
                </div>
                <div class="stat-card success">
                    <i class="fas fa-check-circle stat-icon"></i>
                    <div class="stat-value">
                        <%
                            long activeCount = 0;
                            Date now = new Date();
                            for (Election e : elections) {
                                if (e.getStartDate().before(now) && e.getEndDate().after(now)) {
                                    activeCount++;
                                }
                            }
                        %>
                        <%= activeCount %>
                    </div>
                    <div class="stat-label"><i class="fas fa-fire"></i> Élections Actives</div>
                </div>
                <div class="stat-card warning">
                    <i class="fas fa-clock stat-icon"></i>
                    <div class="stat-value">
                        <%
                            long upcomingCount = 0;
                            for (Election e : elections) {
                                if (e.getStartDate().after(now)) {
                                    upcomingCount++;
                                }
                            }
                        %>
                        <%= upcomingCount %>
                    </div>
                    <div class="stat-label"><i class="fas fa-hourglass-start"></i> À Venir</div>
                </div>
                <div class="stat-card danger">
                    <i class="fas fa-users stat-icon"></i>
                    <div class="stat-value">
                        <%
                            long totalVoters = 0;
                            for (Long count : voterCounts.values()) {
                                totalVoters += count;
                            }
                        %>
                        <%= totalVoters %>
                    </div>
                    <div class="stat-label"><i class="fas fa-vote-yea"></i> Total Votants</div>
                </div>
            </div>
        </div>

        <% if(session.getAttribute("message") != null) { %>
            <div class="alert alert-success alert-dismissible fade show" style="border-radius: 12px;">
                <i class="fas fa-check-circle"></i>
                <%= session.getAttribute("message") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                <% session.removeAttribute("message"); %>
            </div>
        <% } %>
        <% if(session.getAttribute("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show" style="border-radius: 12px;">
                <i class="fas fa-exclamation-circle"></i>
                <%= session.getAttribute("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                <% session.removeAttribute("error"); %>
            </div>
        <% } %>

        <!-- Elections List -->
        <% if(elections.isEmpty()) { %>
            <div class="election-card">
                <div class="empty-state">
                    <i class="fas fa-inbox"></i>
                    <h3>Aucune élection</h3>
                    <p>Commencez par créer votre première élection.</p>
                </div>
            </div>
        <% } else { %>
            <% for(Election election : elections) {
                String status;
                String badgeClass;
                if (election.getStartDate().after(now)) {
                    status = "À venir";
                    badgeClass = "badge-upcoming";
                } else if (election.getEndDate().before(now)) {
                    status = "Terminée";
                    badgeClass = "badge-ended";
                } else {
                    status = "Active";
                    badgeClass = "badge-active";
                }

                List<Candidate> candidates = electionCandidates.get(election.getId());
                Map<Long, Long> votesForCandidates = candidateVoteCounts.get(election.getId());
                long totalVotes = 0;
                for (Long voteCount : votesForCandidates.values()) {
                    totalVotes += voteCount;
                }
            %>
                <div class="election-card">
                    <div class="election-header">
                        <div>
                            <h3 class="election-title">
                                <i class="fas fa-award"></i> <%= election.getTitle() %>
                            </h3>
                            <p class="text-muted mb-0"><%= election.getDescription() %></p>
                        </div>
                        <span class="election-badge <%= badgeClass %>">
                            <i class="fas fa-circle"></i> <%= status %>
                        </span>
                    </div>

                    <div class="election-info">
                        <div class="info-item">
                            <i class="fas fa-calendar-start"></i>
                            <span><strong>Début:</strong> <%= dateFormat.format(election.getStartDate()) %></span>
                        </div>
                        <div class="info-item">
                            <i class="fas fa-calendar-end"></i>
                            <span><strong>Fin:</strong> <%= dateFormat.format(election.getEndDate()) %></span>
                        </div>
                        <div class="info-item">
                            <i class="fas fa-users"></i>
                            <span><strong>Votants:</strong> <%= voterCounts.get(election.getId()) %></span>
                        </div>
                        <div class="info-item">
                            <i class="fas fa-user-friends"></i>
                            <span><strong>Candidats:</strong> <%= candidates.size() %></span>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <h5 class="mb-3"><i class="fas fa-chart-pie"></i> Distribution des Votes</h5>
                            <div class="chart-container">
                                <canvas id="chart<%= election.getId() %>"></canvas>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <h5 class="mb-3"><i class="fas fa-table"></i> Résultats Détaillés</h5>
                            <div class="table-responsive">
                                <table class="table table-custom">
                                    <thead>
                                        <tr>
                                            <th>Candidat</th>
                                            <th>Votes</th>
                                            <th>%</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for(Candidate candidate : candidates) {
                                            long votes = votesForCandidates.get(candidate.getId());
                                            double percentage = totalVotes > 0 ? (votes * 100.0 / totalVotes) : 0;
                                        %>
                                            <tr>
                                                <td><i class="fas fa-user"></i> <%= candidate.getName() %></td>
                                                <td><strong><%= votes %></strong></td>
                                                <td>
                                                    <div class="progress" style="height: 25px;">
                                                        <div class="progress-bar progress-bar-custom bg-primary"
                                                             style="width: <%= percentage %>%">
                                                            <%= String.format("%.1f%%", percentage) %>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="action-buttons mt-3">
                        <a href="editElection.jsp?id=<%= election.getId() %>"
                           class="btn btn-primary btn-icon" title="Éditer">
                            <i class="fas fa-edit"></i>
                        </a>
                        <a href="deleteElection?id=<%= election.getId() %>"
                           class="btn btn-danger btn-icon" title="Supprimer"
                           onclick="return confirm('Êtes-vous sûr de vouloir supprimer cette élection ?')">
                            <i class="fas fa-trash"></i>
                        </a>
                    </div>
                </div>

                <script>
                    // Create chart for election <%= election.getId() %>
                    (function() {
                        var ctx = document.getElementById('chart<%= election.getId() %>').getContext('2d');
                        new Chart(ctx, {
                            type: 'doughnut',
                            data: {
                                labels: [
                                    <% for(int i = 0; i < candidates.size(); i++) { %>
                                        '<%= candidates.get(i).getName() %>'<%= i < candidates.size() - 1 ? "," : "" %>
                                    <% } %>
                                ],
                                datasets: [{
                                    data: [
                                        <% for(int i = 0; i < candidates.size(); i++) { %>
                                            <%= votesForCandidates.get(candidates.get(i).getId()) %><%= i < candidates.size() - 1 ? "," : "" %>
                                        <% } %>
                                    ],
                                    backgroundColor: [
                                        '#4f46e5', '#06b6d4', '#10b981', '#f59e0b', '#ef4444',
                                        '#8b5cf6', '#ec4899', '#14b8a6', '#f97316', '#6366f1'
                                    ]
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        position: 'bottom',
                                    },
                                    title: {
                                        display: false
                                    }
                                }
                            }
                        });
                    })();
                </script>
            <% } %>
        <% } %>

        <!-- Create Election Button -->
        <div class="text-center mt-4 mb-5">
            <a href="createElection.jsp" class="create-button btn">
                <i class="fas fa-plus-circle"></i> Créer une Nouvelle Élection
            </a>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<% hibernateSession.close(); %>

