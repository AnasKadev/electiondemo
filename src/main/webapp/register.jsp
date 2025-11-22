<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription - Système de Vote Électronique</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --success-gradient: linear-gradient(135deg, #10b981 0%, #059669 100%);
            --danger-color: #ef4444;
            --dark-color: #1f2937;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--primary-gradient);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 15px;
            position: relative;
            overflow-x: hidden;
            overflow-y: auto;
        }

        /* Animated Background Elements */
        body::before {
            content: '';
            position: absolute;
            width: 500px;
            height: 500px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            top: -250px;
            right: -250px;
            animation: float 20s infinite ease-in-out;
        }

        body::after {
            content: '';
            position: absolute;
            width: 400px;
            height: 400px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            bottom: -200px;
            left: -200px;
            animation: float 15s infinite ease-in-out reverse;
        }

        @keyframes float {
            0%, 100% {
                transform: translate(0, 0) rotate(0deg);
            }
            33% {
                transform: translate(30px, -50px) rotate(120deg);
            }
            66% {
                transform: translate(-20px, 20px) rotate(240deg);
            }
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
        }

        .register-container {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 480px;
            animation: slideUp 0.6s ease-out;
            margin: 15px auto;
        }

        .register-card {
            background: white;
            border-radius: 24px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            overflow: hidden;
            transition: transform 0.3s ease;
        }

        .register-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 25px 70px rgba(0, 0, 0, 0.35);
        }

        .card-header-custom {
            background: var(--success-gradient);
            padding: 1.5rem 1.5rem;
            text-align: center;
            color: white;
            position: relative;
        }

        .logo-container {
            width: 60px;
            height: 60px;
            background: white;
            border-radius: 50%;
            margin: 0 auto 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
            animation: pulse 2s infinite;
        }

        .logo-container i {
            font-size: 2rem;
            background: var(--success-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .card-header-custom h1 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 0.25rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
        }

        .card-header-custom p {
            font-size: 0.85rem;
            opacity: 0.95;
            margin: 0;
        }

        .card-body-custom {
            padding: 1.5rem 1.5rem;
        }

        .alert-custom {
            border-radius: 10px;
            padding: 0.75rem 1rem;
            margin-bottom: 1rem;
            border: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            animation: slideUp 0.4s ease-out;
        }

        .alert-danger-custom {
            background: #fee2e2;
            color: #991b1b;
        }

        .alert-danger-custom i {
            font-size: 1rem;
        }

        .form-group-custom {
            margin-bottom: 1rem;
            position: relative;
        }

        .form-label-custom {
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.95rem;
        }

        .form-label-custom i {
            color: #10b981;
        }

        .input-group-custom {
            position: relative;
        }

        .input-icon {
            position: absolute;
            left: 0.875rem;
            top: 50%;
            transform: translateY(-50%);
            color: #9ca3af;
            font-size: 1rem;
            z-index: 2;
        }

        .form-control-custom {
            width: 100%;
            padding: 0.75rem 1rem 0.75rem 2.75rem;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 0.95rem;
            transition: all 0.3s ease;
            background: white;
        }

        .form-control-custom:focus {
            outline: none;
            border-color: #10b981;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
            transform: translateY(-2px);
        }

        .form-control-custom.valid {
            border-color: #10b981;
        }

        .form-control-custom.invalid {
            border-color: #ef4444;
        }

        .password-toggle {
            position: absolute;
            right: 1rem;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #9ca3af;
            z-index: 2;
            transition: color 0.3s ease;
        }

        .password-toggle:hover {
            color: #10b981;
        }

        .password-strength {
            margin-top: 0.5rem;
            height: 4px;
            background: #e5e7eb;
            border-radius: 2px;
            overflow: hidden;
            display: none;
        }

        .password-strength-bar {
            height: 100%;
            width: 0;
            transition: all 0.3s ease;
            border-radius: 2px;
        }

        .strength-weak {
            width: 33%;
            background: #ef4444;
        }

        .strength-medium {
            width: 66%;
            background: #f59e0b;
        }

        .strength-strong {
            width: 100%;
            background: #10b981;
        }

        .password-hint {
            font-size: 0.8rem;
            color: #6b7280;
            margin-top: 0.5rem;
        }

        .btn-register {
            width: 100%;
            padding: 0.875rem;
            border: none;
            border-radius: 10px;
            background: var(--success-gradient);
            color: white;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4);
            margin-top: 0.5rem;
        }

        .btn-register:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 25px rgba(16, 185, 129, 0.5);
        }

        .btn-register:active {
            transform: translateY(-1px);
        }

        .divider {
            display: flex;
            align-items: center;
            text-align: center;
            margin: 1rem 0;
            color: #9ca3af;
            font-size: 0.85rem;
        }

        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            border-bottom: 1px solid #e5e7eb;
        }

        .divider span {
            padding: 0 0.75rem;
            font-weight: 500;
        }

        .btn-login {
            width: 100%;
            padding: 0.875rem;
            border: 2px solid #10b981;
            border-radius: 10px;
            background: white;
            color: #10b981;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
            text-align: center;
        }

        .btn-login:hover {
            background: #10b981;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.3);
        }

        .requirements-list {
            background: #f9fafb;
            border-radius: 10px;
            padding: 0.875rem;
            margin-top: 1rem;
        }

        .requirements-list h6 {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--dark-color);
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .requirement-item {
            font-size: 0.8rem;
            color: #6b7280;
            margin-bottom: 0.35rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .requirement-item i {
            font-size: 0.7rem;
        }

        .requirement-item:last-child {
            margin-bottom: 0;
        }

        @media (max-width: 576px) {
            .register-container {
                max-width: 100%;
                margin: 10px auto;
            }

            .card-body-custom {
                padding: 1.25rem 1rem;
            }

            .card-header-custom {
                padding: 1.25rem 1rem;
            }

            .logo-container {
                width: 50px;
                height: 50px;
            }

            .logo-container i {
                font-size: 1.5rem;
            }

            .card-header-custom h1 {
                font-size: 1.25rem;
            }
        }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="register-card">
            <div class="card-header-custom">
                <div class="logo-container">
                    <i class="fas fa-user-plus"></i>
                </div>
                <h1><i class="fas fa-id-card"></i> Inscription</h1>
                <p>Créez votre compte votant</p>
            </div>

            <div class="card-body-custom">
                <% if(request.getAttribute("error") != null) { %>
                    <div class="alert-custom alert-danger-custom">
                        <i class="fas fa-exclamation-circle"></i>
                        <span><%= request.getAttribute("error") %></span>
                    </div>
                <% } %>

                <form action="register" method="post" id="registerForm">
                    <div class="form-group-custom">
                        <label for="username" class="form-label-custom">
                            <i class="fas fa-user"></i>
                            Nom d'utilisateur
                        </label>
                        <div class="input-group-custom">
                            <i class="fas fa-user input-icon"></i>
                            <input
                                type="text"
                                class="form-control-custom"
                                id="username"
                                name="username"
                                placeholder="Choisissez un nom d'utilisateur"
                                autocomplete="username"
                                minlength="3"
                                required>
                        </div>
                        <div class="password-hint">
                            <i class="fas fa-info-circle"></i> Minimum 3 caractères
                        </div>
                    </div>

                    <div class="form-group-custom">
                        <label for="password" class="form-label-custom">
                            <i class="fas fa-lock"></i>
                            Mot de passe
                        </label>
                        <div class="input-group-custom">
                            <i class="fas fa-lock input-icon"></i>
                            <input
                                type="password"
                                class="form-control-custom"
                                id="password"
                                name="password"
                                placeholder="Créez un mot de passe sécurisé"
                                autocomplete="new-password"
                                minlength="6"
                                required>
                            <i class="fas fa-eye password-toggle" id="togglePassword"></i>
                        </div>
                        <div class="password-strength" id="passwordStrength">
                            <div class="password-strength-bar" id="strengthBar"></div>
                        </div>
                        <div class="password-hint" id="strengthText"></div>
                    </div>

                    <div class="form-group-custom">
                        <label for="confirmPassword" class="form-label-custom">
                            <i class="fas fa-check-circle"></i>
                            Confirmer le mot de passe
                        </label>
                        <div class="input-group-custom">
                            <i class="fas fa-check-circle input-icon"></i>
                            <input
                                type="password"
                                class="form-control-custom"
                                id="confirmPassword"
                                name="confirmPassword"
                                placeholder="Confirmez votre mot de passe"
                                autocomplete="new-password"
                                required>
                            <i class="fas fa-eye password-toggle" id="toggleConfirmPassword"></i>
                        </div>
                        <div class="password-hint" id="matchText"></div>
                    </div>

                    <div class="requirements-list">
                        <h6>
                            <i class="fas fa-shield-alt"></i>
                            Exigences du mot de passe
                        </h6>
                        <div class="requirement-item">
                            <i class="fas fa-check-circle" style="color: #10b981;"></i>
                            Au moins 6 caractères
                        </div>
                        <div class="requirement-item">
                            <i class="fas fa-check-circle" style="color: #10b981;"></i>
                            Mélange de lettres et chiffres recommandé
                        </div>
                    </div>

                    <button type="submit" class="btn-register">
                        <i class="fas fa-user-check"></i> Créer mon compte
                    </button>
                </form>

                <div class="divider">
                    <span>Déjà inscrit ?</span>
                </div>

                <a href="login.jsp" class="btn-login">
                    <i class="fas fa-sign-in-alt"></i> Se connecter
                </a>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Password toggle functionality
        const togglePassword = document.getElementById('togglePassword');
        const toggleConfirmPassword = document.getElementById('toggleConfirmPassword');
        const passwordInput = document.getElementById('password');
        const confirmPasswordInput = document.getElementById('confirmPassword');

        togglePassword.addEventListener('click', function() {
            const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordInput.setAttribute('type', type);
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });

        toggleConfirmPassword.addEventListener('click', function() {
            const type = confirmPasswordInput.getAttribute('type') === 'password' ? 'text' : 'password';
            confirmPasswordInput.setAttribute('type', type);
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });

        // Password strength indicator
        const passwordStrength = document.getElementById('passwordStrength');
        const strengthBar = document.getElementById('strengthBar');
        const strengthText = document.getElementById('strengthText');

        passwordInput.addEventListener('input', function() {
            const password = this.value;
            passwordStrength.style.display = password.length > 0 ? 'block' : 'none';

            let strength = 0;
            if (password.length >= 6) strength++;
            if (password.length >= 8) strength++;
            if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
            if (/\d/.test(password)) strength++;
            if (/[^a-zA-Z\d]/.test(password)) strength++;

            strengthBar.className = 'password-strength-bar';
            if (strength <= 2) {
                strengthBar.classList.add('strength-weak');
                strengthText.innerHTML = '<i class="fas fa-exclamation-triangle" style="color: #ef4444;"></i> Mot de passe faible';
                strengthText.style.color = '#ef4444';
            } else if (strength <= 3) {
                strengthBar.classList.add('strength-medium');
                strengthText.innerHTML = '<i class="fas fa-info-circle" style="color: #f59e0b;"></i> Mot de passe moyen';
                strengthText.style.color = '#f59e0b';
            } else {
                strengthBar.classList.add('strength-strong');
                strengthText.innerHTML = '<i class="fas fa-check-circle" style="color: #10b981;"></i> Mot de passe fort';
                strengthText.style.color = '#10b981';
            }
        });

        // Password match validation
        const matchText = document.getElementById('matchText');

        confirmPasswordInput.addEventListener('input', function() {
            if (this.value.length > 0) {
                if (this.value === passwordInput.value) {
                    this.classList.add('valid');
                    this.classList.remove('invalid');
                    matchText.innerHTML = '<i class="fas fa-check-circle" style="color: #10b981;"></i> Les mots de passe correspondent';
                    matchText.style.color = '#10b981';
                } else {
                    this.classList.add('invalid');
                    this.classList.remove('valid');
                    matchText.innerHTML = '<i class="fas fa-times-circle" style="color: #ef4444;"></i> Les mots de passe ne correspondent pas';
                    matchText.style.color = '#ef4444';
                }
            } else {
                this.classList.remove('valid', 'invalid');
                matchText.innerHTML = '';
            }
        });

        // Form validation
        const registerForm = document.getElementById('registerForm');
        registerForm.addEventListener('submit', function(e) {
            const username = document.getElementById('username').value.trim();
            const password = passwordInput.value;
            const confirmPassword = confirmPasswordInput.value;

            if (username.length < 3) {
                e.preventDefault();
                alert('Le nom d\'utilisateur doit contenir au moins 3 caractères.');
                return false;
            }

            if (password.length < 6) {
                e.preventDefault();
                alert('Le mot de passe doit contenir au moins 6 caractères.');
                return false;
            }

            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Les mots de passe ne correspondent pas.');
                return false;
            }
        });

        // Auto-focus on username input
        window.addEventListener('load', function() {
            document.getElementById('username').focus();
        });
    </script>
</body>
</html>

