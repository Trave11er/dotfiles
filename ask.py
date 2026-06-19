#!/usr/bin/env python3
import argparse
import os
import sys
from openai import OpenAI

def main():
    parser = argparse.ArgumentParser(description="Ask OpenAI for a bash command")
    parser.add_argument("question", help="What you want to do")
    parser.add_argument("--model", default="gpt-4o-mini", help="OpenAI model (default: gpt-4o-mini)")
    args = parser.parse_args()

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("OPENAI_API_KEY not set", file=sys.stderr)
        sys.exit(1)

    client = OpenAI(api_key=api_key)

    response = client.chat.completions.create(
        model=args.model,
        messages=[
            {
                "role": "system",
                "content": "Return only a single bash command with no explanation, markdown, or code fences."
            },
            {
                "role": "user",
                "content": args.question
            }
        ]
    )

    command = response.choices[0].message.content.strip()
    print(command)

    while True:
        choice = input("\n[y] execute  [e] explain  [n] cancel: ").strip().lower()
        if choice == "y":
            os.system(command)
            break
        elif choice == "e":
            explain = client.chat.completions.create(
                model=args.model,
                messages=[
                    {
                        "role": "user",
                        "content": f"Explain what this bash command does:\n{command}"
                    }
                ]
            )
            print("\n" + explain.choices[0].message.content.strip())
        elif choice == "n":
            break

if __name__ == "__main__":
    main()