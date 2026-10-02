"""Generate fake users with the Faker library.
   pip install faker
   python make_users.py 100     ->  users_faker.csv
"""
import csv, sys
from faker import Faker

count = int(sys.argv[1]) if len(sys.argv) > 1 else 50
fake = Faker("en_US")
Faker.seed(7)
departments = {
    "IT": ["Systems Administrator", "Help Desk Analyst", "Network Engineer"],
    "HR": ["HR Generalist", "Recruiter"],
    "Finance": ["Accountant", "Financial Analyst"],
    "Sales": ["Account Executive", "Sales Rep"],
    "Operations": ["Operations Analyst", "Logistics Coordinator"],
    "Marketing": ["Content Specialist", "Designer"],
}
used, rows = set(), []
while len(rows) < count:
    first, last = fake.first_name(), fake.last_name()
    sam = (first[0] + last).lower().replace("'", "").replace(" ", "")[:20]
    if sam in used:
        continue
    used.add(sam)
    dept = fake.random_element(list(departments))
    rows.append({
        "FirstName": first, "LastName": last, "SamAccountName": sam,
        "DisplayName": f"{first} {last}", "Department": dept,
        "JobTitle": fake.random_element(departments[dept]),
        "Office": fake.random_element(["Atlanta", "Chicago", "Dallas", "Denver"]),
    })
with open("users_faker.csv", "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=rows[0].keys())
    w.writeheader()
    w.writerows(rows)
print(f"Wrote {len(rows)} users to users_faker.csv")
