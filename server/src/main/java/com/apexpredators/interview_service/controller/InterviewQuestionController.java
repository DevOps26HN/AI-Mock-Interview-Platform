package com.apexpredators.interview_service.controller;

import com.apexpredators.interview_service.model.InterviewQuestion;
import com.apexpredators.interview_service.service.InterviewQuestionService;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@CrossOrigin(origins = "*")
public class InterviewQuestionController {

    private final InterviewQuestionService interviewQuestionService;

    public InterviewQuestionController(InterviewQuestionService interviewQuestionService) {
        this.interviewQuestionService = interviewQuestionService;
    }

    @GetMapping("/api/interview/questions")
    public List<InterviewQuestion> getInterviewQuestions() {
        return interviewQuestionService.getInterviewQuestions();
    }
}