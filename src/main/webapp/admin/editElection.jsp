<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.voting.entities.*" %>
<%@ page import="org.hibernate.*" %>
<%@ page import="com.voting.util.HibernateUtil" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    if (session.getAttribute("user") == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect("../login.jsp");
        return;
    }

    User currentUser = (User) session.getAttribute("user");
    String electionIdParam = request.getParameter("id");

    if (electionIdParam == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    Long electionId = Long.parseLong(electionIdParam);
    Session hibernateSession = HibernateUtil.getSessionFactory().openSession();
    Election election = hibernateSession.get(Election.class, electionId);

    if (election == null) {
        hibernateSession.close();
        response.sendRedirect("dashboard.jsp");
        return;
    }

    List<Candidate> candidates = hibernateSession.createQuery(
        "FROM Candidate c WHERE c.election.id = :electionId",
        Candidate.class)
        .setParameter("electionId", electionId)
        .list();

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm");
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modifier l'Élection</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #4f46e5;
            --secondary-color: #06b6d4;
            --success-color: #10b981;
            --danger-color: #ef4444;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 2rem 0;
        }

        .navbar-custom {
            background: white;
            padding: 1rem 0;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 2rem;
        }

        .form-container {
            background: white;
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            animation: slideUp 0.5s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-label {
            font-weight: 600;
            color: #374151;
            margin-bottom: 0.5rem;
        }

        .form-control, .form-select {
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            padding: 0.75rem;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(79, 70, 229, 0.1);
        }

        .candidate-item {
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            padding: 1rem;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            transition: all 0.3s ease;
        }

        .candidate-item:hover {
            border-color: var(--primary-color);
            box-shadow: 0 4px 12px rgba(79, 70, 229, 0.1);
        }

        .btn-add-candidate {
            background: linear-gradient(135deg, var(--success-color), #059669);
            color: white;
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-add-candidate:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.3);
        }

        .btn-remove-candidate {
            background: var(--danger-color);
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 8px;
            transition: all 0.3s ease;
        }

        .btn-remove-candidate:hover {
            background: #dc2626;
            transform: scale(1.05);
        }

        .btn-submit {
            background: linear-gradient(135deg, var(--primary-color), #4338ca);
            color: white;
            border: none;
            padding: 1rem 3rem;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s ease;
        }

        .btn-submit:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(79, 70, 229, 0.3);
        }

        .btn-cancel {
            background: #6b7280;
            color: white;
            border: none;
            padding: 1rem 3rem;
            border-radius: 12px;
            font-weight: 600;
            font-size: 1.1rem;
            transition: all 0.3s ease;
        }

        .btn-cancel:hover {
            background: #4b5563;
            transform: translateY(-2px);
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--primary-color);
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 3px solid var(--primary-color);
        }
    </style>
</head>
<body>
    <nav class="navbar-custom">
        <div class="container-fluid">
            <div class="d-flex justify-content-between align-items-center w-100">
                <h4 class="m-0"><i class="fas fa-edit"></i> Modifier l'Élection</h4>
                <div>
                    <span class="me-3"><i class="fas fa-user-shield"></i> <%= currentUser.getUsername() %></span>
                    <a href="../logout" class="btn btn-outline-danger btn-sm">
                        <i class="fas fa-sign-out-alt"></i> Déconnexion
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <div class="container">
        <div class="form-container">
            <h2 class="text-center mb-4">
                <i class="fas fa-poll"></i> Modifier l'Élection
            </h2>

            <% if(session.getAttribute("error") != null) { %>
                <div class="alert alert-danger alert-dismissible fade show">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= session.getAttribute("error") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                    <% session.removeAttribute("error"); %>
                </div>
            <% } %>

            <form action="editElection" method="post" id="editElectionForm">
                <input type="hidden" name="electionId" value="<%= election.getId() %>">

                <!-- Election Details -->
                <div class="section-title">
                    <i class="fas fa-info-circle"></i> Informations de l'Élection
                </div>

                <div class="mb-3">
                    <label for="title" class="form-label">
                        <i class="fas fa-heading"></i> Titre de l'Élection *
                    </label>
                    <input type="text" class="form-control" id="title" name="title"
                           value="<%= election.getTitle() %>" required>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">
                        <i class="fas fa-align-left"></i> Description *
                    </label>
                    <textarea class="form-control" id="description" name="description"
                              rows="3" required><%= election.getDescription() %></textarea>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label for="startDate" class="form-label">
                            <i class="fas fa-calendar-start"></i> Date de Début *
                        </label>
                        <input type="datetime-local" class="form-control" id="startDate"
                               name="startDate" value="<%= dateFormat.format(election.getStartDate()) %>" required>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label for="endDate" class="form-label">
                            <i class="fas fa-calendar-end"></i> Date de Fin *
                        </label>
                        <input type="datetime-local" class="form-control" id="endDate"
                               name="endDate" value="<%= dateFormat.format(election.getEndDate()) %>" required>
                    </div>
                </div>

                <!-- Candidates Section -->
                <div class="section-title mt-4">
                    <i class="fas fa-users"></i> Candidats
                </div>

                <div id="candidatesContainer">
                    <% for (int i = 0; i < candidates.size(); i++) {
                        Candidate candidate = candidates.get(i);
                    %>
                        <div class="candidate-item">
                            <input type="hidden" name="candidateIds[]" value="<%= candidate.getId() %>">
                            <div class="flex-grow-1">
                                <label class="form-label mb-1">
                                    <i class="fas fa-user"></i> Candidat <%= i + 1 %>
                                </label>
                                <input type="text" class="form-control" name="candidateNames[]"
                                       value="<%= candidate.getName() %>" placeholder="Nom du candidat" required>
                            </div>
                            <button type="button" class="btn-remove-candidate" onclick="removeCandidate(this)">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    <% } %>
                </div>

                <button type="button" class="btn btn-add-candidate w-100 mb-4" onclick="addCandidate()">
                    <i class="fas fa-plus-circle"></i> Ajouter un Candidat
                </button>

                <!-- Action Buttons -->
                <div class="d-flex justify-content-between gap-3 mt-4">
                    <a href="dashboard.jsp" class="btn btn-cancel">
                        <i class="fas fa-times"></i> Annuler
                    </a>
                    <button type="submit" class="btn btn-submit">
                        <i class="fas fa-save"></i> Enregistrer les Modifications
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let candidateCount = <%= candidates.size() %>;

        function addCandidate() {
            candidateCount++;
            const container = document.getElementById('candidatesContainer');
            const candidateDiv = document.createElement('div');
            candidateDiv.className = 'candidate-item';
            candidateDiv.innerHTML = `
                <input type="hidden" name="candidateIds[]" value="">
                <div class="flex-grow-1">
                    <label class="form-label mb-1">
                        <i class="fas fa-user"></i> Candidat ${candidateCount}
                    </label>
                    <input type="text" class="form-control" name="candidateNames[]"
                           placeholder="Nom du candidat" required>
                </div>
                <button type="button" class="btn-remove-candidate" onclick="removeCandidate(this)">
                    <i class="fas fa-trash"></i>
                </button>
            `;
            container.appendChild(candidateDiv);
        }

        function removeCandidate(button) {
            const candidateItem = button.closest('.candidate-item');
            candidateItem.remove();
            updateCandidateNumbers();
        }

        function updateCandidateNumbers() {
            const candidates = document.querySelectorAll('.candidate-item');
            candidates.forEach((item, index) => {
                const label = item.querySelector('.form-label');
                label.innerHTML = `<i class="fas fa-user"></i> Candidat ${index + 1}`;
            });
            candidateCount = candidates.length;
        }

        document.getElementById('editElectionForm').addEventListener('submit', function(e) {
            const startDate = new Date(document.getElementById('startDate').value);
            const endDate = new Date(document.getElementById('endDate').value);

            if (endDate <= startDate) {
                e.preventDefault();
                alert('La date de fin doit être après la date de début.');
                return false;
            }

            const candidates = document.querySelectorAll('input[name="candidateNames[]"]');
            if (candidates.length < 2) {
                e.preventDefault();
                alert('Vous devez avoir au moins 2 candidats.');
                return false;
            }
        });
    </script>
</body>
</html>
<% hibernateSession.close(); %>

