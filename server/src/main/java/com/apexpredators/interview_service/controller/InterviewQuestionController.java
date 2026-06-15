package com.apexpredators.interview_service.controller;

import com.apexpredators.interview_service.model.InterviewQuestion;
import com.apexpredators.interview_service.service.InterviewQuestionService;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

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

    @PostMapping("/api/interview/questions/{id}/hint")
    public Map<String, String> getQuestionHint(@PathVariable Long id) {
        String hint = interviewQuestionService.getQuestionHint(id);
        return Map.of("hint", hint);
    }
}
