import csv
import json

csv_translations_file = './translations_hep_es.csv'
json_dataset_file = './cascade_3'

with open(csv_translations_file) as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    with open(json_dataset_file + '.json') as json_file:
        dataset_metadata = json.load(json_file)
        first = True
        for row in csv_reader:
            if first:
                first = False
            else:
                metadata_type = row[2]
                object_id = row[1]
                locale = row[3]
                property = row[4]
                value = row[5]
                for object in dataset_metadata[metadata_type]:
                    if object['id'] == object_id and value is not None and value != "":
                        new_translation = {
                            "property": property,
                            "locale": locale,
                            "value": value
                        }
                        object.setdefault('translations', []).append(new_translation)
                        print(object)
        with open(json_dataset_file + '_translated.json', 'w') as outputfile:
            json.dump(dataset_metadata, outputfile, indent=4, ensure_ascii=False)
