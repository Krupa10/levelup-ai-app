class PromptMapper {
  static String buildPrompt(String chip) {
    switch (chip) {
      case "🚀 Career Roadmap":
        return '''
Create a personalized career roadmap for me.

Include:
• Short-term goals
• Long-term goals
• Skills to develop
• Learning resources
• Practical next steps
''';

      case "📄 Resume Review":
        return '''
Help me improve my resume.

If I haven't uploaded one yet,
tell me what makes a strong resume and what sections I should include.
''';

      case "🎤 Interview Prep":
        return '''
Help me prepare for interviews.

Include:
• Common interview questions
• Preparation tips
• Mistakes to avoid
• Confidence tips
''';

      case "💼 Career Switch":
        return '''
Guide me on changing my career.

Help me:
• Evaluate transferable skills
• Learn new skills
• Build experience
• Create an action plan
''';

      case "📈 Skill Growth":
        return '''
Suggest the most valuable skills I should learn next based on my career growth.

Explain why each skill is important.
''';

      case "💰 Salary Advice":
        return '''
Give practical advice on salary growth.

Include:
• Negotiation tips
• Skill improvements
• Career strategies
• Common mistakes
''';

      case "🎓 Higher Studies":
        return '''
Help me decide whether pursuing higher studies is a good choice.

Explain:
• Pros
• Cons
• When it makes sense
• Alternatives
''';

      case "🧠 Productivity":
        return '''
Give me practical productivity tips for career growth.

Include:
• Daily habits
• Time management
• Focus techniques
• Avoiding burnout
''';

      default:
        return chip;
    }
  }
}