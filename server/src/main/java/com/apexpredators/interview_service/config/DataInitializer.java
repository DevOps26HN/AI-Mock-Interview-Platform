package com.apexpredators.interview_service.config;

import com.apexpredators.interview_service.model.InterviewQuestion;
import com.apexpredators.interview_service.repository.InterviewQuestionRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class DataInitializer {

    @Bean
    CommandLineRunner initDatabase(InterviewQuestionRepository repository) {
        return args -> {
            if (repository.count() == 0) {
                System.out.println("Database is empty. Seeding sample data...");
                repository.saveAll(List.of(
                    new InterviewQuestion("Backend Developer", "Can you explain the difference between REST and GraphQL?", "Technical", "Easy"),
                    new InterviewQuestion("DevOps Engineer", "How would you debug a failed CI/CD pipeline?", "Technical", "Medium"),
                    new InterviewQuestion("Software Engineer", "Tell me about a time when you had to solve a difficult technical problem.", "Behavioral", "Medium")
                ));
                System.out.println("Sample data seeded successfully.");
            } else {
                System.out.println("Database already contains data. Skipping seeding.");
            }
        };
    }
}
