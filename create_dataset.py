import os
import random
import string

os.makedirs("data", exist_ok=True)


def generate_unique_filename(folder: str, length: int = 5, ext: str = ".txt") -> str:
    """Return a random filename (length chars + ext) not already present in folder."""
    existing = set(os.listdir(folder))
    chars = string.ascii_letters + string.digits
    while True:
        name = "".join(random.choices(chars, k=length)) + ext
        if name not in existing:
            return name


def create_data_file(folder: str = "data") -> str:
    """
    Create a txt file inside *folder* with:
      - A random 5-char name not already present in the folder.
      - A single paragraph: 10–20 sentences separated by '. ', all on one line.
      - At least one sentence of exactly max_length chars (randomly chosen from [20, 50]).
      - The chosen max_length value as the very last line (plain integer).

    Returns the path of the created file.
    """
    os.makedirs(folder, exist_ok=True)

    allowed = string.ascii_letters + string.digits + " "
    max_length = random.randint(20, 50)
    num_sentences = random.randint(10, 20)

    # Anchor sentence is exactly max_length chars
    anchor = "".join(random.choices(allowed, k=max_length)).strip() or "A"

    # Remaining sentences are random length up to max_length
    others = [
        "".join(random.choices(allowed, k=random.randint(1, max_length))).strip() or "A"
        for _ in range(num_sentences - 1)
    ]

    sentences = [anchor] + others
    random.shuffle(sentences)

    filename = generate_unique_filename(folder)
    filepath = os.path.join(folder, filename)

    with open(filepath, "w") as f:
        f.write(".".join(sentences) + ".\n")
        f.write(str(max_length) + "\n")

    return filepath


if __name__ == "__main__":
    path = create_data_file()
    print(f"Created: {path}")
