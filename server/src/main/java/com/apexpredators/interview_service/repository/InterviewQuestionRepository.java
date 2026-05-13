package com.apexpredators.interview_service.repository;

import com.apexpredators.interview_service.model.InterviewQuestion;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class InterviewQuestionRepository {

    public List<InterviewQuestion> findAll() {
        return List.of(
                new InterviewQuestion(
                        1L,
                        "Backend Developer",
                        "Can you explain the difference between REST and GraphQL?",
                        "Technical",
                        "Easy"),
                new InterviewQuestion(
                        2L,
                        "DevOps Engineer",
                        "How would you debug a failed CI/CD pipeline?",
                        "Technical",
                        "Medium"),
                new InterviewQuestion(
                        3L,
                        "Software Engineer",
                        "Tell me about a time when you had to solve a difficult technical problem.",
                        "Behavioral",
                        "Medium"));
    }
}