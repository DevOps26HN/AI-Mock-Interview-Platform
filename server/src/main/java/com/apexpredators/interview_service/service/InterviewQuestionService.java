package com.apexpredators.interview_service.service;

import com.apexpredators.interview_service.model.InterviewQuestion;
import com.apexpredators.interview_service.repository.InterviewQuestionRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class InterviewQuestionService {

    private static final Logger logger = LoggerFactory.getLogger(InterviewQuestionService.class);

    private final InterviewQuestionRepository interviewQuestionRepository;
    private final RestTemplate restTemplate;

    @Value("${genai.url:http://localhost:8000}")
    private String genAiUrl;

    public InterviewQuestionService(InterviewQuestionRepository interviewQuestionRepository, RestTemplate restTemplate) {
        this.interviewQuestionRepository = interviewQuestionRepository;
        this.restTemplate = restTemplate;
    }

    public List<InterviewQuestion> getInterviewQuestions() {
        return interviewQuestionRepository.findAll();
    }

    public String getQuestionHint(Long id) {
        logger.info("Requesting hint for question ID: {}", id);
        Optional<InterviewQuestion> questionOpt = interviewQuestionRepository.findById(id);
        if (questionOpt.isEmpty()) {
            logger.warn("Question not found for ID: {}", id);
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Question not found");
        }
        InterviewQuestion q = questionOpt.get();

        Map<String, String> request = new HashMap<>();
        request.put("question", q.getQuestion());
        request.put("role", q.getRole());
        request.put("category", q.getCategory());

        String endpoint = genAiUrl + "/generate-hint";
        logger.info("Calling GenAI service at: {}", endpoint);

        try {
            Map<String, Object> response = restTemplate.postForObject(endpoint, request, Map.class);
            if (response != null && response.containsKey("hint")) {
                logger.info("Successfully received hint for question ID: {}", id);
                return (String) response.get("hint");
            }
            logger.error("Invalid response format from GenAI service for ID: {}", id);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Invalid response from GenAI service");
        } catch (Exception e) {
            logger.error("Failed to generate hint for question ID: {}. Error: {}", id, e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error generating hint: " + e.getMessage(), e);
        }
    }
}
