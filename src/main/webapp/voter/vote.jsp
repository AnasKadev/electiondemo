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

    Long electionId = Long.parseLong(request.getParameter("electionId"));
    User currentUser = (User) session.getAttribute("user");
    Session hibernateSession = HibernateUtil.getSessionFactory().openSession();

    Election election = hibernateSession.get(Election.class, electionId);
    List<Candidate> candidates = hibernateSession.createQuery(
        "FROM Candidate WHERE election.id = :electionId",
        Candidate.class
    ).setParameter("electionId", electionId)
    .list();

    // Check if user already voted
    Long voteCount = hibernateSession.createQuery(
        "SELECT COUNT(*) FROM Vote v WHERE v.user.id = :userId AND v.election.id = :electionId",
        Long.class
    ).setParameter("userId", currentUser.getId())
     .setParameter("electionId", electionId)
     .uniqueResult();

    boolean hasVoted = voteCount > 0;

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vote - <%= election.getTitle() %></title>
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

        .vote-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem 1rem;
        }

        .election-header {
            background: white;
            border-radius: 20px;
            padding: 2.5rem;
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

        .election-title {
            color: var(--dark-color);
            font-weight: 700;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .election-meta {
            display: flex;
            gap: 2rem;
            margin-top: 1rem;
            flex-wrap: wrap;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: #6b7280;
        }

        .meta-item i {
            color: var(--primary-color);
        }

        .progress-section {
            background: white;
            border-radius: 20px;
            padding: 1.5rem 2.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .progress-steps {
            display: flex;
            justify-content: space-between;
            align-items: center;
            position: relative;
        }

        .progress-line {
            position: absolute;
            top: 20px;
            left: 10%;
            right: 10%;
            height: 3px;
            background: #e5e7eb;
            z-index: 0;
        }

        .progress-fill {
            height: 100%;
            background: var(--success-color);
            transition: width 0.3s ease;
        }

        .step {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            z-index: 1;
        }

        .step-circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: white;
            border: 3px solid #e5e7eb;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: #9ca3af;
            transition: all 0.3s ease;
        }

        .step.active .step-circle {
            background: var(--primary-color);
            border-color: var(--primary-color);
            color: white;
        }

        .step.completed .step-circle {
            background: var(--success-color);
            border-color: var(--success-color);
            color: white;
        }

        .step-label {
            margin-top: 0.5rem;
            font-size: 0.85rem;
            color: #6b7280;
            font-weight: 500;
        }

        .candidates-section {
            background: white;
            border-radius: 20px;
            padding: 2.5rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
        }

        .section-title {
            color: var(--dark-color);
            font-weight: 600;
            margin-bottom: 2rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .candidate-card {
            border: 3px solid #e5e7eb;
            border-radius: 15px;
            padding: 1.5rem;
            transition: all 0.3s ease;
            cursor: pointer;
            position: relative;
            margin-bottom: 1.5rem;
            animation: fadeIn 0.5s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: scale(0.95);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }

        .candidate-card:hover {
            border-color: var(--primary-color);
            box-shadow: 0 10px 25px rgba(79, 70, 229, 0.15);
            transform: translateY(-5px);
        }

        .candidate-card.selected {
            border-color: var(--success-color);
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.05), rgba(16, 185, 129, 0.1));
            box-shadow: 0 10px 30px rgba(16, 185, 129, 0.2);
        }

        .candidate-card input[type="radio"] {
            position: absolute;
            opacity: 0;
        }

        .candidate-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            font-weight: 600;
            margin-right: 1.5rem;
            flex-shrink: 0;
        }

        .candidate-info {
            flex: 1;
        }

        .candidate-name {
            font-size: 1.3rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 0.5rem;
        }

        .candidate-description {
            color: #6b7280;
            line-height: 1.6;
        }

        .check-icon {
            position: absolute;
            top: 1rem;
            right: 1rem;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: var(--success-color);
            color: white;
            display: none;
            align-items: center;
            justify-content: center;
        }

        .candidate-card.selected .check-icon {
            display: flex;
            animation: scaleIn 0.3s ease-out;
        }

        @keyframes scaleIn {
            from {
                transform: scale(0);
            }
            to {
                transform: scale(1);
            }
        }

        .action-buttons {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }

        .btn-custom {
            flex: 1;
            padding: 1rem;
            border-radius: 12px;
            font-weight: 600;
            transition: all 0.3s ease;
            border: none;
            font-size: 1.1rem;
        }

        .btn-submit {
            background: linear-gradient(135deg, var(--success-color), #059669);
            color: white;
        }

        .btn-submit:hover:not(:disabled) {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(16, 185, 129, 0.3);
        }

        .btn-submit:disabled {
            background: #d1d5db;
            cursor: not-allowed;
        }

        .btn-back {
            background: #6b7280;
            color: white;
        }

        .btn-back:hover {
            background: #4b5563;
            transform: translateY(-3px);
        }

        .alert-custom {
            border-radius: 12px;
            border: none;
            padding: 1rem 1.5rem;
            margin-bottom: 2rem;
            animation: slideDown 0.5s ease-out;
        }

        .already-voted {
            text-align: center;
            padding: 3rem;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }

        .already-voted i {
            font-size: 5rem;
            color: var(--success-color);
            margin-bottom: 1rem;
        }

        /* Confirmation Modal Styling */
        .modal-content {
            border-radius: 20px;
            border: none;
        }

        .modal-header {
            background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
            color: white;
            border-radius: 20px 20px 0 0;
        }

        .modal-body {
            padding: 2rem;
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

    <div class="vote-container">
        <% if(hasVoted) { %>
            <div class="already-voted">
                <i class="fas fa-check-circle"></i>
                <h2>Vous avez déjà voté!</h2>
                <p class="text-muted mb-4">Vous avez déjà participé à cette élection.</p>
                <a href="dashboard.jsp" class="btn btn-primary btn-lg">
                    <i class="fas fa-arrow-left"></i> Retour au Tableau de Bord
                </a>
            </div>
        <% } else { %>
            <!-- Election Header -->
            <div class="election-header">
                <h1 class="election-title">
                    <i class="fas fa-ballot-check"></i>
                    <%= election.getTitle() %>
                </h1>
                <p class="text-muted"><%= election.getDescription() %></p>

                <div class="election-meta">
                    <div class="meta-item">
                        <i class="fas fa-calendar-start"></i>
                        <span>Début: <%= dateFormat.format(election.getStartDate()) %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-calendar-end"></i>
                        <span>Fin: <%= dateFormat.format(election.getEndDate()) %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-users"></i>
                        <span><%= candidates.size() %> Candidats</span>
                    </div>
                </div>
            </div>

            <!-- Progress Steps -->
            <div class="progress-section">
                <div class="progress-steps">
                    <div class="progress-line">
                        <div class="progress-fill" id="progressFill" style="width: 0%"></div>
                    </div>
                    <div class="step completed">
                        <div class="step-circle"><i class="fas fa-check"></i></div>
                        <span class="step-label">Sélection</span>
                    </div>
                    <div class="step active" id="step2">
                        <div class="step-circle">2</div>
                        <span class="step-label">Choix</span>
                    </div>
                    <div class="step" id="step3">
                        <div class="step-circle">3</div>
                        <span class="step-label">Confirmation</span>
                    </div>
                </div>
            </div>

            <% if(request.getAttribute("error") != null) { %>
                <div class="alert alert-danger alert-custom">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <!-- Candidates Section -->
            <div class="candidates-section">
                <h3 class="section-title">
                    <i class="fas fa-user-friends"></i>
                    Choisissez votre candidat
                </h3>

                <form id="voteForm" action="../vote" method="post">
                    <input type="hidden" name="electionId" value="<%= election.getId() %>">

                    <% for(int i = 0; i < candidates.size(); i++) {
                        Candidate candidate = candidates.get(i);
                        String initial = candidate.getName().substring(0, 1).toUpperCase();
                    %>
                        <label class="candidate-card" for="candidate<%= candidate.getId() %>">
                            <input type="radio"
                                   name="candidateId"
                                   value="<%= candidate.getId() %>"
                                   id="candidate<%= candidate.getId() %>"
                                   onchange="selectCandidate(this)"
                                   required>
                            <div class="d-flex align-items-center">
                                <div class="candidate-avatar"><%= initial %></div>
                                <div class="candidate-info">
                                    <div class="candidate-name">
                                        <i class="fas fa-user"></i> <%= candidate.getName() %>
                                    </div>
                                    <div class="candidate-description">
                                        <%= candidate.getDescription() != null ? candidate.getDescription() : "Candidat pour cette élection" %>
                                    </div>
                                </div>
                                <div class="check-icon">
                                    <i class="fas fa-check"></i>
                                </div>
                            </div>
                        </label>
                    <% } %>

                    <div class="action-buttons">
                        <a href="dashboard.jsp" class="btn-custom btn-back">
                            <i class="fas fa-arrow-left"></i> Annuler
                        </a>
                        <button type="button" class="btn-custom btn-submit" id="submitBtn"
                                onclick="confirmVote()" disabled>
                            <i class="fas fa-check-circle"></i> Confirmer mon vote
                        </button>
                    </div>
                </form>
            </div>
        <% } %>
    </div>

    <!-- Confirmation Modal -->
    <div class="modal fade" id="confirmModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-exclamation-triangle"></i>
                        Confirmer votre vote
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="text-center mb-3">
                        <i class="fas fa-vote-yea" style="font-size: 4rem; color: var(--primary-color);"></i>
                    </div>
                    <h5 class="text-center mb-3">Êtes-vous sûr de votre choix?</h5>
                    <p class="text-center text-muted">
                        Vous êtes sur le point de voter pour <strong id="selectedCandidateName"></strong>.
                        <br><br>
                        <span class="text-warning">
                            <i class="fas fa-info-circle"></i>
                            Cette action est définitive et ne peut pas être annulée.
                        </span>
                    </p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
                        <i class="fas fa-times"></i> Annuler
                    </button>
                    <button type="button" class="btn btn-success" onclick="submitVote()">
                        <i class="fas fa-check"></i> Confirmer le vote
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let selectedCandidate = null;
        const confirmModal = new bootstrap.Modal(document.getElementById('confirmModal'));

        function selectCandidate(radio) {
            // Remove selected class from all cards
            document.querySelectorAll('.candidate-card').forEach(card => {
                card.classList.remove('selected');
            });

            // Add selected class to the parent label
            radio.parentElement.classList.add('selected');

            // Store selected candidate info
            selectedCandidate = {
                id: radio.value,
                name: radio.parentElement.querySelector('.candidate-name').textContent.trim()
            };

            // Enable submit button
            document.getElementById('submitBtn').disabled = false;

            // Update progress
            document.getElementById('progressFill').style.width = '50%';
            document.getElementById('step2').classList.remove('active');
            document.getElementById('step2').classList.add('completed');
            document.getElementById('step2').querySelector('.step-circle').innerHTML = '<i class="fas fa-check"></i>';
            document.getElementById('step3').classList.add('active');
        }

        function confirmVote() {
            if (!selectedCandidate) {
                alert('Veuillez sélectionner un candidat');
                return;
            }

            document.getElementById('selectedCandidateName').textContent = selectedCandidate.name;
            confirmModal.show();
        }

        function submitVote() {
            document.getElementById('progressFill').style.width = '100%';
            document.getElementById('voteForm').submit();
        }

        // Add animation delay to candidate cards
        document.querySelectorAll('.candidate-card').forEach((card, index) => {
            card.style.animationDelay = (index * 0.1) + 's';
        });
    </script>
</body>
</html>
<% hibernateSession.close(); %>

