"""
analyze_data.py
---------------
For every .txt file in data/:
  - Read the full file content verbatim.
  - Use nltk.sent_tokenize() to extract all sentences.
  - Find the longest sentence(s) by character length.
  - Print results to the terminal.
  - Save the longest sentence(s) to output/<filename>.longest.txt
  - Append a row (filename, longest_length) to answer.csv

Configuration is read from environment variables (with defaults):
  DATA_DIR    — directory containing input .txt files  (default: "data")
  OUTPUT_DIR  — directory for output .longest.txt files (default: "output")
  ANSWER_CSV  — path to the aggregated results CSV      (default: "answer.csv")
"""

import csv
import os

import nltk
from nltk.tokenize import sent_tokenize

# Download Punkt tokenizer models if not already present
nltk.download("punkt_tab", quiet=True)

# ── Configuration from environment ───────────────────────────────────────────
DATA_DIR   = os.environ.get("DATA_DIR",   "data")
OUTPUT_DIR = os.environ.get("OUTPUT_DIR", "output")
ANSWER_CSV = os.environ.get("ANSWER_CSV", "answer.csv")

CSV_HEADER = ["filename", "longest_length"]


def read_content(filepath: str) -> str:
    """Read and return the full text of *filepath* without any assumptions about structure."""
    with open(filepath, "r") as f:
        return f.read()


def find_longest_sentences(text: str) -> tuple[int, list[str]]:
    """Tokenize *text* into sentences; return (max_length, [sentences at max_length])."""
    sentences = sent_tokenize(text)
    if not sentences:
        return 0, []
    max_len = max(len(s) for s in sentences)
    return max_len, [s for s in sentences if len(s) == max_len]


def ensure_csv_header(csv_path: str) -> None:
    if not os.path.exists(csv_path) or os.path.getsize(csv_path) == 0:
        with open(csv_path, "w", newline="") as f:
            csv.writer(f).writerow(CSV_HEADER)


def append_csv_row(csv_path: str, filename: str, longest_length: int) -> None:
    with open(csv_path, "a", newline="") as f:
        csv.writer(f).writerow([filename, longest_length])


def main() -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    ensure_csv_header(ANSWER_CSV)

    txt_files = sorted(f for f in os.listdir(DATA_DIR) if f.endswith(".txt"))

    if not txt_files:
        print(f"No .txt files found in '{DATA_DIR}/'.")
        return

    for filename in txt_files:
        filepath = os.path.join(DATA_DIR, filename)
        content = read_content(filepath)
        all_sentences = sent_tokenize(content)
        max_len, longest = find_longest_sentences(content)

        # ── Terminal output ───────────────────────────────────────────────────
        print(f"\n{'─' * 60}")
        print(f"File       : {filename}")
        print(f"Sentences  : {len(all_sentences)}")
        print(f"Max length : {max_len} chars  ({len(longest)} tied)")
        for i, s in enumerate(longest, 1):
            print(f"  [{i}] {s!r}")

        # ── Save to output/<filename>.longest.txt ─────────────────────────────
        out_path = os.path.join(OUTPUT_DIR, filename.split('.')[0] + ".longest.txt")
        with open(out_path, "w") as f:
            f.write(f"filename: {filename}\n")
            f.write(f"longest_length: {max_len}\n")
            f.write(f"count: {len(longest)}\n")
            f.write("sentences:\n")
            for s in longest:
                f.write(s + "\n")

        # ── Append row to answer.csv ──────────────────────────────────────────
        append_csv_row(ANSWER_CSV, filename, max_len)
        print(f"  → Saved: {out_path}  |  CSV row appended.")

    print(f"\n{'─' * 60}")
    print(f"Done. Results in '{OUTPUT_DIR}/'  |  Summary in '{ANSWER_CSV}'.")


if __name__ == "__main__":
    main()
