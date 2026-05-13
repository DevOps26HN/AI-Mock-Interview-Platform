package com.apexpredators.interview_service.model;

public class InterviewQuestion {
    private Long id;
    private String role;
    private String question;
    private String category;
    private String difficulty;

    public InterviewQuestion(Long id, String role, String question, String category, String difficulty) {
        this.id = id;
        this.role = role;
        this.question = question;
        this.category = category;
        this.difficulty = difficulty;
    }

    public Long getId() {
        return id;
    }

    public String getRole() {
        return role;
    }

    public String getQuestion() {
        return question;
    }

    public String getCategory() {
        return category;
    }

    public String getDifficulty() {
        return difficulty;
    }
}