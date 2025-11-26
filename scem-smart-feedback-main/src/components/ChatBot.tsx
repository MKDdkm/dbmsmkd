import React, { useRef, useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { MessageSquare } from 'lucide-react';

type Message = { role: 'user' | 'assistant'; text: string };

const ChatBot: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([
    { role: 'assistant', text: 'Hi! I can help you write or improve feedback for your faculty. Ask me anything.' },
  ]);
  const [input, setInput] = useState('');
  const [sending, setSending] = useState(false);
  const listRef = useRef<HTMLDivElement | null>(null);

  const scrollToBottom = () => {
    setTimeout(() => {
      if (listRef.current) listRef.current.scrollTop = listRef.current.scrollHeight;
    }, 50);
  };

  const sendMessage = async () => {
    const trimmed = input.trim();
    if (!trimmed) return;
    const userMsg: Message = { role: 'user', text: trimmed };
    setMessages((m) => [...m, userMsg]);
    setInput('');
    setSending(true);
    scrollToBottom();

    try {
      // Try backend AI endpoint; fall back to a helpful canned reply on failure
      const res = await fetch(`${import.meta.env.VITE_API_URL}/api/ai/chat`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: trimmed }),
      });

      if (res.ok) {
        const data = await res.json();
        const reply = (data?.reply as string) || 'Sorry, I could not generate a reply.';
        setMessages((m) => [...m, { role: 'assistant', text: reply }]);
      } else {
        // fallback helpful suggestions
        setMessages((m) => [
          ...m,
          {
            role: 'assistant',
            text:
              "I couldn't reach the AI service. Meanwhile, try: 'I appreciated the clear explanations, but would like more examples.' or ask me to rephrase your comment for politeness.",
          },
        ]);
      }
    } catch (err) {
      setMessages((m) => [
        ...m,
        {
          role: 'assistant',
          text:
            "Network error while contacting AI service. You can still ask for example phrasing like: 'Could you help me rephrase this feedback to be more constructive?'.",
        },
      ]);
    } finally {
      setSending(false);
      scrollToBottom();
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <MessageSquare className="h-5 w-5" />
          AI Chatbot
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex flex-col h-64">
          <div ref={listRef} className="flex-1 overflow-auto space-y-3 mb-3 p-2 border rounded">
            {messages.map((m, i) => (
              <div
                key={i}
                className={`px-3 py-2 rounded-lg max-w-[80%] ${
                  m.role === 'user' ? 'ml-auto bg-primary/10 text-primary' : 'mr-auto bg-muted'
                }`}
              >
                <div className="text-sm">{m.text}</div>
              </div>
            ))}
          </div>

          <div className="flex items-start gap-2">
            <Textarea
              className="flex-1"
              rows={2}
              placeholder="Ask the assistant to help write or refine feedback..."
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault();
                  sendMessage();
                }
              }}
            />
            <Button onClick={sendMessage} disabled={sending} className="h-10">
              {sending ? 'Sending...' : 'Send'}
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default ChatBot;
