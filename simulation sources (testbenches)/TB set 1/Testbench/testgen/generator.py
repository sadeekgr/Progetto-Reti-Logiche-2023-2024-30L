import os
import re
import click
import random

input_file = 'template.txt'
output_dir = 'testbench/'
dir = os.path.dirname(__file__)

def word_replace(text, dict):
    rc = re.compile(r'[A-Za-z_]\w*')

    def translate(match):
        word = match.group(0)
        #print(word)
        return dict.get(word, word)

    return rc.sub(translate, text)

@click.command()
@click.option('--amount', default=1, show_default=True, help='Amount of generated testbenches')
@click.option('--name', default='gen', show_default=True, help='Prefix of generated files')
def main(amount, name):
    
    for i in range(amount):

        k = random.randint(1, 100)
        add = random.randint(0, 65335)

        def get_w():
            return random.randint(0, 255) if random.randint(0, 2) > random.randint(1, 2) else 0

        input_ram = [get_w() if j%2 == 0 else 0 for j in range(2*k)]
        output_ram = []

        prev = 0
        conf = 0
        for j,num in enumerate(input_ram):
            if j%2 == 0:
                if num == 0:
                    output_ram.append(prev)
                    conf = conf - 1 if conf > 0 else conf
                else:
                    output_ram.append(num)
                    prev = num
                    conf = 31
            else:
                output_ram.append(conf)

        replace_dict = {
            'NAME_PLACEHOLDER' : name + str(i), 
            'K_PLACEHOLDER' : str(k), 
            'ADD_PLACEHOLDER' : str(add), 
            'INPUT_PLACEHOLDER' : '(' + ', '.join([str(i) for i in input_ram]) + ')', 
            'OUTPUT_PLACEHOLDER' : '(' + ', '.join([str(i) for i in output_ram]) + ')'
        }

        with open(os.path.join(dir, input_file), 'r') as template:
            filedata = template.read()

        with open(os.path.join(dir, output_dir + name + str(i) + '.vhd'), 'w') as output:
            output.write(word_replace(filedata, replace_dict))


if __name__ == '__main__':
    main()