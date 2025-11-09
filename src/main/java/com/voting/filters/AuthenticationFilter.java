package com.voting.filters;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

public class AuthenticationFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        String requestURI = httpRequest.getRequestURI();

        if (isLoggedIn) {
            String role = (String) session.getAttribute("role");
            if (requestURI.contains("/admin/") && !"ADMIN".equals(role)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/voter/dashboard.jsp");
                return;
            } else if (requestURI.contains("/voter/") && !"VOTER".equals(role)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/admin/dashboard.jsp");
                return;
            }
            chain.doFilter(request, response);
        } else {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
        }
    }

    @Override
    public void destroy() {

    }
}
