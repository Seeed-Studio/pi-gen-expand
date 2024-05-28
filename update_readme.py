# -*- coding: utf-8 -*-
import sys
import re
from datetime import datetime

if __name__ == '__main__':
    
    # 获取命令行参数
    devname, username, password, enable_ssh, stage_list, http = sys.argv[1:]

	# 获取当前日期并格式化
    current_date = datetime.now().strftime('%Y-%m-%d')
    username_password = f"{username} & {password}"
	# 打印传入的全部参数
    print(sys.argv)

    # 读取readme.md文件
    with open('README.md', 'r') as file:
        lines = file.readlines()

    # 标志位，用于判断devname是否已存在
    devname_found = False

    # 尝试在表格中找到devname对应的行并更新
    for i, line in enumerate(lines):
        if f"| {devname}" in line:
            # 更新找到的行
            updated_line = line.split('|')
            updated_line[2] = f" {username_password.ljust(23)} "
            updated_line[3] = f" {enable_ssh.ljust(10)} "  # 假设enable-ssh字段宽度为12，包括1个空格
            updated_line[4] = f" {stage_list.ljust(43)} "  # 假设stage-list字段宽度为24，包括1个空格
            updated_line[5] = f" [{current_date}]({http})"
            lines[i] = '|'.join(updated_line)
            devname_found = True
            break

    # 如果devname不存在，则在表格下方新增一行
    if not devname_found:
        new_line = f"| {devname.ljust(21)} | {username_password.ljust(23)} | {enable_ssh.ljust(10)} | {stage_list.ljust(43)} | [{current_date}]({http}) |\n"
        # 找到表格结束的位置（假设表格之后是空行或者文件结束）
        for i, line in enumerate(lines):
            if len(line.strip()) == 0 and i > 6:
                lines.insert(i, new_line)  # 在空行之前插入新行
                break
        else:  # 如果文件没有空行，则在文件末尾插入新行
            lines.append(new_line)

    # 更新readme.md文件第5行后的内容 
    with open('README.md', 'w') as file:
        file.writelines(lines)
