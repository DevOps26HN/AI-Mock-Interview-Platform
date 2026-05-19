package com.apexpredators.interview_service.model;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class InterviewQuestion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String role;
    private String question;
    private String category;
    private String difficulty;

    public InterviewQuestion() {}

    public InterviewQuestion(String role, String question, String category, String difficulty) {
        this.role = role;
        this.question = question;
        this.category = category;
        this.difficulty = difficulty;
    }

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

    public void setId(Long id) {
        this.id = id;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }
}
