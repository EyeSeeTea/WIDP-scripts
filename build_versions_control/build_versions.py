#!/usr/bin/env python
import csv
import json
import os
from d2apy import dhis2api
import datetime

proxy = 'http://openproxy.who.int:8080/'

os.environ['http_proxy'] = proxy
os.environ['HTTP_PROXY'] = proxy
os.environ['https_proxy'] = proxy
os.environ['HTTPS_PROXY'] = proxy

def init_api(url, username, password):
    return dhis2api.Dhis2Api(url, username, password)


def update_html(file_path):
    f = open(file_path, "w")
    f.write('<html><head>\n'
            '<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-+0n0xVW2eSR5OomGNYDnhzAbDsOXxcvSN1TPprVMTNDbiYZCxYbOOl7+AMvyTG2x" crossorigin="anonymous">\n'
            '<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>\n'
            '<script src="https://cdn.datatables.net/1.10.16/js/jquery.dataTables.min.js"></script>\n'
            '<script src="https://cdn.datatables.net/1.10.16/js/dataTables.bootstrap4.min.js"></script>\n'
            '<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/js/bootstrap.bundle.min.js" integrity="sha384-gtEjrD/SeCtmISkJkNUaaKMoLD0//ElJ19smozuHV6z3Iehds+3Ulb9Bn9Plx0x4" crossorigin="anonymous"></script>\n'
            '<script>$(document).ready(function() {'
            '$("#builds_table").DataTable( {"pageLength": 15, "order": [[ 0, "asc" ]]}); } );'
            '</script>\n'
            '</head><body><div class="table-responsive">'
            '<table id="builds_table" class="styled-table  table-hover table-striped table" style="width:100%">\n')
    with open('versions.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        total_rows = sum(1 for i in csv_reader)
        line_count = 0
        is_header = True
        with open('versions.csv') as csv_file:
            csv_reader = csv.reader(csv_file, delimiter=',')
            for row in csv_reader:

                if line_count == 0:
                    f.write("<thead>\n")
                f.write("<tr>")
                row_count= 0
                for row_item in row:
                    if line_count == 0:
                        if is_header:
                            f.write("<th scope=\"col\">#</th>\n")
                            f.write("<th scope=\"col\"><b>{}</b></th>\n".format(row_item))
                            is_header = False
                        else:
                            f.write("<th scope=\"col\"><b>{}</b></th>\n".format(row_item))
                    else:
                        if is_header:
                            f.write("<th scope=\"row\">{}</th>\n".format(str(total_rows-line_count)))
                            f.write("<td>{}</td>\n".format(row_item))
                            is_header = False
                        else:
                            if row_count == 3:
                                import datetime
                                date = datetime.datetime.strptime(row_item, '%d/%m/%Y')
                                data_sort_value = datetime.date.strftime(date,'%Y%m%d')
                                f.write("<td data-sort={}>{}</td>\n".format(data_sort_value, row_item))
                            else:
                                f.write("<td>{}</td>\n".format(row_item))
                    row_count = row_count +1
                f.write("</tr>\n")
                if line_count == 0:
                    f.write("</thead>")
                    f.write("<tbody>")
                line_count += 1
                is_header = True
            print(f'Processed {line_count} lines.')
    f.write("</tbody></table></div></body></html>")
    f.close()


def main():
    with open("config.json") as f:
        config = json.load(f)

        with open("info.json", "r") as read_file:
            data = json.load(read_file)
            keys = []
            for instance in data["instances"]:
                for instance_name in instance.keys():
                    actual_revision = instance[instance_name]["revision"]
                    server = instance[instance_name]["server"]

                    dapi = init_api(server, config["username"], config["password"])
                    response = dapi.get("/system/info")
                    new_revision = response["revision"]
                    new_version = response["version"]
                    if new_revision != actual_revision:
                        keys.append(instance_name)
                        instance[instance_name]["previousRevision"] = actual_revision
                        instance[instance_name]["revision"] = new_revision
                        instance[instance_name]["version"] = new_version
            for instance in data["instances"]:
                for instance_name in instance.keys():
                    if instance_name in keys:
                        with open('versions.csv', 'a') as fd:
                            x = datetime.datetime.now()
                            linetowrite= [instance_name, instance[instance_name]["version"],
                                          instance[instance_name]["revision"], x.strftime("%d/%m/%Y")]
                            fd.write(",".join(linetowrite)+"\n")

            if len(keys) > 0:
                with open("info.json", "w") as write_file:
                    json.dump(data, write_file)
                update_html(config["table_path"])

if __name__ == "__main__":
    main()
