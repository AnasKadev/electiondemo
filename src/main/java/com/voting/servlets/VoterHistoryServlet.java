package com.voting.servlets;

import com.voting.entities.*;
import com.voting.util.HibernateUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.hibernate.Session;

import java.io.IOException;
import java.util.*;

@WebServlet("/voter/history")
public class VoterHistoryServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession httpSession = request.getSession(false);
        if (httpSession == null || httpSession.getAttribute("user") == null) {
            response.sendRedirect("../login.jsp");
            return;
        }

        User user = (User) httpSession.getAttribute("user");
        Session hibernateSession = HibernateUtil.getSessionFactory().openSession();

        try {
            // Get user's voting history
            List<Vote> votes = hibernateSession.createQuery(
                "FROM Vote v WHERE v.user.id = :userId ORDER BY v.voteDate DESC",
                Vote.class
            ).setParameter("userId", user.getId()).list();

            request.setAttribute("votes", votes);
            request.getRequestDispatcher("history.jsp").forward(request, response);
        } finally {
            hibernateSession.close();
        }
    }
}

