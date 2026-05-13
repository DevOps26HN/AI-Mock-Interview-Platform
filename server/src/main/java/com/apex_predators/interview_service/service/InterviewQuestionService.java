package com.apex_predators.interview_service.service;

import com.apex_predators.interview_service.model.InterviewQuestion;
import com.apex_predators.interview_service.repository.InterviewQuestionRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class InterviewQuestionService {

    private final InterviewQuestionRepository interviewQuestionRepository;

    public InterviewQuestionService(InterviewQuestionRepository interviewQuestionRepository) {
        this.interviewQuestionRepository = interviewQuestionRepository;
    }

    public List<InterviewQuestion> getInterviewQuestions() {
        return interviewQuestionRepository.findAll();
    }
}
