#!/usr/bin/python3
import subprocess
import difflib
import os
import configparser

def dump_schema(host, port, user, password, dbname, filename):
    command = [
        "mysqldump",
        "-h", host,
        "-P", str(port),
        "-u", user,
        f"-p{password}",
        "--no-data",
        "--skip-comments",
        "--skip-add-locks",
        "--skip-disable-keys",
        "--compact",
        dbname
    ]
    with open(filename, "w") as f:
        subprocess.run(command, stdout=f)

def clean_schema(input_file, output_file):
    with open(input_file, "r") as f:
        lines = f.readlines()

    clean_lines = []
    for line in lines:
        if (
            "AUTO_INCREMENT" in line
            or "DEFINER=" in line
            or line.strip().startswith("/*")
            or line.strip().startswith("--")
        ):
            continue
        clean_lines.append(line)

    with open(output_file, "w") as f:
        f.writelines(sorted(clean_lines))

def compare_files(file1, file2):
    with open(file1, "r") as f1, open(file2, "r") as f2:
        diff = difflib.unified_diff(
            f1.readlines(),
            f2.readlines(),
            fromfile=file1,
            tofile=file2
        )
        for line in diff:
            print(line, end="")

def load_config():
    config = configparser.ConfigParser()
    config.read("dbcompare.ini")
    db1 = {
        "host": config.get("db1", "host"),
        "port": config.getint("db1", "port"),
        "user": config.get("db1", "user"),
        "password": config.get("db1", "password"),
        "dbname": config.get("db1", "dbname")
    }
    db2 = {
        "host": config.get("db2", "host"),
        "port": config.getint("db2", "port"),
        "user": config.get("db2", "user"),
        "password": config.get("db2", "password"),
        "dbname": config.get("db2", "dbname")
    }
    return db1, db2

def main():
    db1, db2 = load_config()

    # === DUMP ===
    dump_schema(**db1, filename="schema1.sql")
    dump_schema(**db2, filename="schema2.sql")

    # === CLEAN ===
    clean_schema("schema1.sql", "clean1.sql")
    clean_schema("schema2.sql", "clean2.sql")

    # === COMPARE ===
    print("\n=== SCHEMA DIFFERENCES ===\n")
    compare_files("clean1.sql", "clean2.sql")

    # === CLEANUP === (optional)
    # os.remove("schema1.sql")
    # os.remove("schema2.sql")
    # os.remove("clean1.sql")
    # os.remove("clean2.sql")

if __name__ == "__main__":
    main()

