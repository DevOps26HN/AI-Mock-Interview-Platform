package com.apexpredators.interview_service.service;

import com.apexpredators.interview_service.model.InterviewQuestion;
import com.apexpredators.interview_service.repository.InterviewQuestionRepository;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
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
    private final MeterRegistry meterRegistry;

    @Value("${genai.url:http://localhost:8000}")
    private String genAiUrl;

    public InterviewQuestionService(InterviewQuestionRepository interviewQuestionRepository, RestTemplate restTemplate, MeterRegistry meterRegistry) {
        this.interviewQuestionRepository = interviewQuestionRepository;
        this.restTemplate = restTemplate;
        this.meterRegistry = meterRegistry;
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

        Timer.Sample sample = Timer.start(meterRegistry);
        String status = "200";
        String outcome = "SUCCESS";

        try {
            Map<String, Object> response = restTemplate.postForObject(endpoint, request, Map.class);
            if (response != null && response.containsKey("hint")) {
                logger.info("Successfully received hint for question ID: {}", id);
                return (String) response.get("hint");
            }
            logger.error("Invalid response format from GenAI service for ID: {}", id);
            status = "500";
            outcome = "SERVER_ERROR";
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Invalid response from GenAI service");
        } catch (org.springframework.web.client.HttpStatusCodeException e) {
            logger.error("GenAI service returned error status {}: {}", e.getStatusCode(), e.getResponseBodyAsString());
            status = String.valueOf(e.getStatusCode().value());
            outcome = e.getStatusCode().is5xxServerError() ? "SERVER_ERROR" : "CLIENT_ERROR";
            throw new ResponseStatusException(e.getStatusCode(), "GenAI error: " + e.getResponseBodyAsString(), e);
        } catch (Exception e) {
            logger.error("Failed to generate hint for question ID: {}. Error: {}", id, e.getMessage());
            status = "500";
            outcome = "SERVER_ERROR";
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Error generating hint: " + e.getMessage(), e);
        } finally {
            sample.stop(Timer.builder("http_client_requests_seconds")
                    .tag("client_name", "genai")
                    .tag("uri", "/generate-hint")
                    .tag("status", status)
                    .tag("outcome", outcome)
                    .register(meterRegistry));
        }
    }
}
