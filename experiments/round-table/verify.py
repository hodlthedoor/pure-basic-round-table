"""Independent verifier for experimental Dudeney schedules (1-based labels)."""


def verify(n, rows):
    if not 3 <= n <= 21 or len(rows) != (n - 1) * (n - 2) // 2:
        return False
    people = set(range(1, n + 1))
    seen = {person: set() for person in people}
    for row in rows:
        if len(row) != n or set(row) != people:
            return False
        for position, person in enumerate(row):
            neighbours = frozenset((row[position - 1], row[(position + 1) % n]))
            if neighbours in seen[person]:
                return False
            seen[person].add(neighbours)
    # The correct number of unique pairs drawn from the other n-1 people
    # is sufficient to establish complete coverage.
    return all(len(pairs) == (n - 1) * (n - 2) // 2 for pairs in seen.values())
