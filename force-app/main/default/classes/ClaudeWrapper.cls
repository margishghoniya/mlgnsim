public without sharing class ClaudeWrapper {

    /** REQUEST WRAPPERS
     ******************************************************************/

    public class Request {

        public String model;
        public Integer max_tokens;
       // public Decimal temperature;
        public List<Message> messages;

        public Request() {
            messages = new List<Message>();
        }
    }

    public class Message {

        public String role;
        public List<Content> content;

        public Message() {
            content = new List<Content>();
        }
    }

    public class Content {

        public String type;
        public String text;
    }


    /***** RESPONSE WRAPPERS
     ******************************************************************/

    public class Response {

        public String id;
        public String type;
        public String role;
        public String model;

        public List<ResponseContent> content;

        public String stop_reason;
        public String stop_sequence;

        public Usage usage;
    }

    public class ResponseContent {

        public String type;
        public String text;
    }

    public class Usage {
        public Integer input_tokens;
        public Integer output_tokens;
    }


    /****ERROR WRAPPERS
     ******************************************************************/

    public class ErrorResponse {
        public String type;
        public Error error;
    }

    public class Error {
        public String type;
        public String message;
    }

}