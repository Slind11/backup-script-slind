#!/bin/bash

#########################################################################################################
#      Данный скрипт предназначен для создания резервной копии указанной пользователем директории       #  
# архивации файлов и удаления старых резервных копий в соответствии с установленными правилами хранения #
#########################################################################################################


echo "Введите путь директории откуда будут сделаны бэкапы: "
read Backup_directory 

echo "Директория откуда будут делаться бэкапы установлена:  $Backup_directory"

echo "Введите директорию куда будут делаться бэкапы: "
read Backup_save

#Проверерка на то есть ли это директория

if [ ! -d "$Backup_save" ]; then
   echo "Указанная директория отстутсвует, переходим к созданию"
   mkdir -p "$Backup_save"

   echo "Директория $Backup_save была создана"

else

   echo  "Директория $Backup_save уже существует"

fi
 

#Проверка наличия архиватора tar

if ! which tar &> /dev/null; then
    echo "Архиватор не установлен, требуется установка"
    exit 1
fi

echo "Архиватор tar установлен."

#Создание функции, которая преднозначена для создания имени файла бэкапа 

generate_backup_filename() {
    local Backup_directory="$1"
    local Backup_type="$2"
    local Current_date=$(date +"%Y%m%d_%H%M%S")
    echo "${Backup_type}_Backup_${Current_date}_$(basename "$Backup_directory").tar.gz"
}

func_backup() {
   local Backup_directory="$1"
   local Backup_save="$2"
   local Backup_type="$3"
   local Backup_filename=$(generate_backup_filename "$Backup_directory" "$Backup_type")
   
   tar -czf "$Backup_save/$Backup_filename" -C "$Backup_directory" .

   echo "Бэкап успешно завершен в: $Backup_save с именем $Backup_filename"
}

# Определение текущего дня недели
Current_day=$(date '+%w')


# Создание бэкапа в зависимости от текущего дня недели
if [ "$Current_day" -eq 0 ]; then
    func_backup "$Backup_directory" "$Backup_save" "weekly"
elif [ "$(date '+%-d')" -eq 1 ]; then
    func_backup "$Backup_directory" "$Backup_save" "monthly"
elif [ "$(date '+%-m')" -eq 12 ] && [ "$(date '+%-d')" -eq 31 ]; then
    func_backup "$Backup_directory" "$Backup_save" "yearly"
else
    func_backup "$Backup_directory" "$Backup_save" "daily"
fi


