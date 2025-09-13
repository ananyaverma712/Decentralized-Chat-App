module MyModule::DecentralizedChat {
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Struct representing a chat message
    struct Message has store, copy, drop {
        sender: address,
        content: String,
        timestamp: u64,
    }

    /// Struct representing a user's chat history
    struct ChatHistory has store, key {
        messages: vector<Message>,
    }

    /// Function to initialize a user's chat history
    public fun initialize_chat(user: &signer) {
        let chat_history = ChatHistory {
            messages: vector::empty<Message>(),
        };
        move_to(user, chat_history);
    }

    /// Function to send a message to another user
    public fun send_message(
        sender: &signer,
        recipient: address,
        content: String
    ) acquires ChatHistory {
        let sender_addr = signer::address_of(sender);
        
        // Create new message
        let message = Message {
            sender: sender_addr,
            content,
            timestamp: timestamp::now_seconds(),
        };

        // Add message to recipient's chat history
        if (!exists<ChatHistory>(recipient)) {
            let chat_history = ChatHistory {
                messages: vector::empty<Message>(),
            };
            move_to(sender, chat_history);
        };

        let recipient_chat = borrow_global_mut<ChatHistory>(recipient);
        vector::push_back(&mut recipient_chat.messages, message);

        // Add message to sender's chat history if it exists
        if (exists<ChatHistory>(sender_addr)) {
            let sender_chat = borrow_global_mut<ChatHistory>(sender_addr);
            vector::push_back(&mut sender_chat.messages, message);
        };
    }
}