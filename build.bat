@echo off
echo ====================================
echo  Compilation du Projet Election Demo
echo ====================================
echo.

cd /d "%~dp0"

echo [1/3] Nettoyage du projet...
call mvn clean
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Echec du nettoyage
    pause
    exit /b 1
)

echo.
echo [2/3] Compilation du projet...
call mvn compile
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Echec de la compilation
    pause
    exit /b 1
)

echo.
echo [3/3] Creation du package WAR...
call mvn package
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Echec de la creation du package
    pause
    exit /b 1
)

echo.
echo ====================================
echo  Compilation reussie !
echo ====================================
echo.
echo Le fichier WAR est disponible dans le dossier target/
echo Vous pouvez le deployer sur Tomcat
echo.
pause

