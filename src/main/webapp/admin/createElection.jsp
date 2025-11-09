<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.voting.entities.*" %>
<%
    // Vérification de l'authentification et du rôle
    User user = (User) session.getAttribute("user");
    if (user == null || !"ADMIN".equals(user.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Créer une nouvelle élection</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-5">
        <h2>Créer une nouvelle élection</h2>

        <% if(request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="../createElection" method="post" class="mt-4">
            <div class="mb-3">
                <label for="title" class="form-label">Titre de l'élection</label>
                <input type="text" class="form-control" id="title" name="title" required>
            </div>

            <div class="mb-3">
                <label for="description" class="form-label">Description</label>
                <textarea class="form-control" id="description" name="description" rows="3" required></textarea>
            </div>

            <div class="mb-3">
                <label for="startDate" class="form-label">Date de début</label>
                <input type="datetime-local" class="form-control" id="startDate" name="startDate" required>
            </div>

            <div class="mb-3">
                <label for="endDate" class="form-label">Date de fin</label>
                <input type="datetime-local" class="form-control" id="endDate" name="endDate" required>
            </div>

            <!-- Section pour les candidats -->
            <h4 class="mt-4">Candidats</h4>
            <div id="candidatesContainer">
                <div class="candidate-entry mb-3 p-3 border rounded">
                    <div class="mb-3">
                        <label class="form-label">Nom du candidat</label>
                        <input type="text" class="form-control" name="candidateNames[]" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description du candidat</label>
                        <textarea class="form-control" name="candidateDescriptions[]" rows="2" required></textarea>
                    </div>
                </div>
            </div>

            <button type="button" class="btn btn-secondary mb-3" onclick="addCandidateField()">
                Ajouter un candidat
            </button>

            <div class="mt-4">
                <button type="submit" class="btn btn-primary">Créer l'élection</button>
                <a href="dashboard.jsp" class="btn btn-secondary ms-2">Annuler</a>
            </div>
        </form>
    </div>

    <script>
        function addCandidateField() {
            const container = document.getElementById('candidatesContainer');
            const newEntry = document.createElement('div');
            newEntry.className = 'candidate-entry mb-3 p-3 border rounded';
            newEntry.innerHTML = `
                <div class="mb-3">
                    <label class="form-label">Nom du candidat</label>
                    <input type="text" class="form-control" name="candidateNames[]" required>
                </div>
                <div class="mb-3">
                    <label class="form-label">Description du candidat</label>
                    <textarea class="form-control" name="candidateDescriptions[]" rows="2" required></textarea>
                </div>
                <button type="button" class="btn btn-danger btn-sm" onclick="this.parentElement.remove()">
                    Supprimer ce candidat
                </button>
            `;
            container.appendChild(newEntry);
        }
    </script>
</body>
</html>
