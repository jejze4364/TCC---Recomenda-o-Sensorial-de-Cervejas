import csv
from statistics import mean

DATA_FILE = 'data/beers.csv'

# Load dataset
beers = []
with open(DATA_FILE, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Convert numeric fields to float
        for key in row:
            if key != 'style':
                row[key] = float(row[key])
        beers.append(row)

# Compute summary statistics
def summarize(field):
    values = [b[field] for b in beers]
    return {
        'min': min(values),
        'max': max(values),
        'avg': mean(values)
    }

fields = ['abv', 'ibu', 'srm', 'sweetness', 'bitterness', 'body',
          'fruity', 'malty', 'roasted', 'citrus', 'floral']

summary = {field: summarize(field) for field in fields}

print('Beer dataset summary ({} beers):'.format(len(beers)))
for field in fields:
    stats = summary[field]
    print(f"{field:10s} min={stats['min']:4.1f} max={stats['max']:4.1f} avg={stats['avg']:4.1f}")
