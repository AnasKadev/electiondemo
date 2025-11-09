<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.voting.entities.User" %>
<%
    User user = (User) session.getAttribute("user");
    if (user != null) {
        if ("ADMIN".equals(user.getRole())) {
            response.sendRedirect("admin/dashboard.jsp");
        } else {
            response.sendRedirect("voter/dashboard.jsp");
        }
    } else {
        response.sendRedirect("login.jsp");
    }
%>

