
# Домашнее задание к занятию «Вычислительные мощности. Балансировщики нагрузки»


Ссылка на [манифесты](https://github.com/vladmgb/cloud2/tree/main/src)

1. Создать бакет Object Storage и разместить в нём файл с картинкой:
- Создать бакет в Object Storage с произвольным именем (например, имя_студента_дата).
  <br>
<br>
<img width="831" height="275" alt="image" src="https://github.com/user-attachments/assets/bd966639-2ed4-48a1-81dc-eb8c0a7f722e" />
<br>
<br>
  - Положить в бакет файл с картинкой.
<br>
<br>
<img width="1116" height="363" alt="image" src="https://github.com/user-attachments/assets/f3d708f7-a182-43eb-9d59-3cb6f4ae8912" />
<br>
<br>
  - Сделать файл доступным из интернета.

  Файл доступен по [ссылке](https://vladmgb-bucket-27102025.storage.yandexcloud.net/image.jpg)
<br>
<br>
<img width="1041" height="242" alt="image" src="https://github.com/user-attachments/assets/be1b72ae-1944-43e5-b6a2-7b9dce4e9f76" />
<br>
<br>
    
2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и веб-страницей, содержащей ссылку на картинку из бакета:
- Создать Instance Group с тремя ВМ и шаблоном LAMP. Для LAMP рекомендуется использовать image_id = fd827b91d99psvq5fjit.
- Для создания стартовой веб-страницы рекомендуется использовать раздел user_data в meta_data.
- Разместить в стартовой веб-странице шаблонной ВМ ссылку на картинку из бакета.
- Настроить проверку состояния ВМ.

Группа ВМ создана:
<br>
<br>
<img width="862" height="495" alt="image" src="https://github.com/user-attachments/assets/3eb83fd2-f469-45dd-ac31-8215712ffd0a" />
<br>
<br>
<img width="1034" height="350" alt="image" src="https://github.com/user-attachments/assets/7d7e06b2-3e6f-42bb-84e8-b8306e0b0b23" />
<br>
<br>
<img width="1067" height="254" alt="image" src="https://github.com/user-attachments/assets/7e5fa5d4-7f12-42eb-a64d-1ef18fad15af" />
<br>
<br>
Странички с картинкой доступны на всех ВМ группы.

3. Подключить группу к сетевому балансировщику:
   
- Создать сетевой балансировщик.
<br>
<br>
<img width="1116" height="222" alt="image" src="https://github.com/user-attachments/assets/1516a0f2-dc10-4b70-a64c-21f46131199d" />
<br>
<br>
<img width="873" height="616" alt="image" src="https://github.com/user-attachments/assets/89937817-1fea-4bc2-b4b1-ed47f5622d66" />
<br>
<br>
Странички с картинкой через NLB доступна:http://158.160.175.72
<br>
<br>
<img width="880" height="576" alt="image" src="https://github.com/user-attachments/assets/9de6fb08-90ec-4c27-a470-92e16b8133cf" />
<br>
<br>
- Проверить работоспособность, удалив одну или несколько ВМ.

Проверка

Удалена 1 ВМ.
<br>
<br>
<img width="606" height="425" alt="image" src="https://github.com/user-attachments/assets/aae3f6f3-2a3c-4de0-b559-cefd5f8a2537" />
<br>
<br>
Удалены 2 ВМ
<br>
<br>
<img width="556" height="433" alt="image" src="https://github.com/user-attachments/assets/de6e3c2b-4157-48db-968f-2249571baf9e" />
<br>
<br>

Страничка с картинкой через NLB все также доступна: http://158.160.175.72

- (дополнительно)* Создать Application Load Balancer с использованием Instance group и проверкой состояния.
<br>
<br>
<img width="727" height="589" alt="image" src="https://github.com/user-attachments/assets/7b7e8ab0-a257-469f-a436-51efe3862272" />
<br>
<br>
Странички с картинкой через ALB доступна: http://158.160.189.64
<br>
<br>
<img width="888" height="522" alt="image" src="https://github.com/user-attachments/assets/2e9a1ec7-a55f-41be-95f3-d9a6c24b96c7" />


