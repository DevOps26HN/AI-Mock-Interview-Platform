package com.apexpredators.interview_service.service;

import com.apexpredators.interview_service.model.InterviewQuestion;
import com.apexpredators.interview_service.repository.InterviewQuestionRepository;
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
