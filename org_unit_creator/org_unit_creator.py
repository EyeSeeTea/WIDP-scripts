import csv
import subprocess
from argparse import ArgumentParser, RawDescriptionHelpFormatter as fmt
import json


def main():
    args = get_args()
    file_input = args.input
    file_output = args.output
    input_level = args.level
    exit_message = "Exiting the program"
    if file_input is None:
        print("Please enter the parameter --input followed by the input filename.")
        print(exit_message)
        exit(1)
    if file_output is None:
        print("Please enter the parameter --output followed by the output filename.")
        print(exit_message)
        exit(1)
    if input_level is None:
        print("Please enter the parameter --level followed by desired levels.")
        print(exit_message)
        exit(1)
    json_output = {"organisationUnits": []}
    print("file input: %s" % (file_input))
    print("file output: %s" % (file_input))
    print("Starting conversion")
    with open(file_input) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        line_count = 0
        for row in csv_reader:
            if line_count == 0:
                line_count += 1
            else:
                line_count += 1
                level = row[0]
                if level not in input_level:
                    continue
                uid = row[1]
                if uid != "":
                    print("The ou with uid:" + uid + " will be override.")
                else:
                    uid = gen_code()
                code = row[2]
                name = row[5]
                parent_uid = row[3]
                if parent_uid == "":
                    print("Exit Error: The parent uid of ou:" + name + " is empty")
                    exit(1)
                short_name = row[6]
                opening_date = row[7]
                description = row[8]
                closing_date = row[9]
                contact = row[10]
                comment = row[11]
                address = row[12]
                email = row[13]
                phone = row[14]
                print("Converting " + name + "with uid: " + uid)
                json_output["organisationUnits"].append({
                    "id": uid,
                    "name": name,
                    "shortName": short_name,
                    "code": code,
                    "description": description,
                    "contactPerson": contact,
                    "openingDate": opening_date,
                    "email": email,
                    "closedDate": closing_date,
                    "comment": comment,
                    "phoneNumber": phone,
                    "address": address,
                    "parent": {"id": parent_uid}})
    print("The process has finished successfully. ")
    orgunits_json = json.dumps(json_output, ensure_ascii=False)

    write(file_output, orgunits_json)

    print("Json file created:" + file_output)


def write(fname, text):
    if fname:
        with open(fname, 'wt', encoding="utf-8") as fout:
            fout.write(text)
    else:
        print(text, end='')


def gen_code():
    command = "java CodeGenerator"
    process = subprocess.Popen(command.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    return str(output).replace("b'", "").replace("\\n'", "")


def get_args():
    "Parse command-line arguments and return them"
    global sort_fields

    parser = ArgumentParser(description=__doc__, formatter_class=fmt)
    add = parser.add_argument  # shortcut
    add('-i', '--input', help='input csv file')
    add('-o', '--output', help='output .json file')
    add('-l', '--level', nargs='*', help='org unit single or multiple levels')
    args = parser.parse_args()

    return args


if __name__ == '__main__':
    main()
