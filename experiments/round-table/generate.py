"""Experimental generator; no production GUI code."""
from math import lcm

from starters import RAW, construction


def expand_starters(n):
    starters, cycles = construction(n)
    successor = {person: person for person in range(1, n + 1)}
    for cycle in cycles:
        for i, person in enumerate(cycle):
            successor[person] = cycle[(i + 1) % len(cycle)]
    rows = []
    for row in starters:
        for _ in range(lcm(*(len(cycle) for cycle in cycles))):
            rows.append(row)
            row = [successor[person] for person in row]
    return rows


def field_tables(q):
    # Small finite fields needed here; coefficients are in ascending order.
    extensions = {4: (2, [1, 1, 1]), 8: (2, [1, 1, 0, 1]),
                  9: (3, [1, 0, 1]), 16: (2, [1, 1, 0, 0, 1])}
    if q not in extensions:
        return ([[ (a + b) % q for b in range(q)] for a in range(q)],
                [[ (a * b) % q for b in range(q)] for a in range(q)])
    p, polynomial = extensions[q]
    degree = len(polynomial) - 1
    coefficients = [[(a // p**j) % p for j in range(degree)] for a in range(q)]
    add = [[0] * q for _ in range(q)]
    multiply = [[0] * q for _ in range(q)]
    for a in range(q):
        for b in range(q):
            add[a][b] = sum((coefficients[a][j] + coefficients[b][j]) % p * p**j
                            for j in range(degree))
            product = [0] * (2 * degree - 1)
            for i in range(degree):
                for j in range(degree):
                    product[i+j] += coefficients[a][i] * coefficients[b][j]
            for j in range(len(product)-1, degree-1, -1):
                for i in range(degree):
                    product[j-degree+i] -= product[j] * polynomial[i]
            multiply[a][b] = sum(product[j] % p * p**j for j in range(degree))
    return add, multiply


def projective_schedule(n):
    # Nakamura et al. (1980), pp. 7–10. Find a full projective cycle,
    # expand all affine images, and keep one of each reversal pair.
    q = n - 1
    add, mul = field_tables(q)
    inverse = [0] + [next(b for b in range(1, q) if mul[a][b] == 1)
                     for a in range(1, q)]
    seed = None
    for a in range(q):
        for b in range(1, q):
            row, x = [], q  # q represents infinity.
            while x not in row:
                row.append(x)
                if x == q:
                    x = mul[a][inverse[b]]
                elif x == 0:
                    x = q
                else:
                    x = mul[add[mul[a][x]][1]][inverse[mul[b][x]]]
            if x == q and len(row) == n:
                seed = row
                break
        if seed:
            break
    if seed is None:
        raise ValueError('No projective cycle found')
    seen, rows = set(), []
    for s in range(1, q):
        for t in range(q):
            # Infinity stays at index 0; reversal also starts at infinity.
            row = tuple(q if x == q else add[mul[s][x]][t] for x in seed)
            key = min(row, (q,) + row[:0:-1])
            if key not in seen:
                seen.add(key)
                rows.append([x + 1 for x in row])
    return rows


def generate(n):
    if not 3 <= n <= 21:
        raise ValueError('Count must be 3–21')
    return expand_starters(n) if n in RAW else projective_schedule(n)
