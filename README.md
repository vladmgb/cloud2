
# Домашнее задание к занятию «Вычислительные мощности. Балансировщики нагрузки»

Что нужно сделать

Ссылка на [манифесты](https://github.com/vladmgb/cloud2/tree/main/src)

1. Создать бакет Object Storage и разместить в нём файл с картинкой:
- Создать бакет в Object Storage с произвольным именем (например, имя_студента_дата).
  
<img width="831" height="275" alt="image" src="https://github.com/user-attachments/assets/bd966639-2ed4-48a1-81dc-eb8c0a7f722e" />

  - Положить в бакет файл с картинкой.

<img width="1116" height="363" alt="image" src="https://github.com/user-attachments/assets/f3d708f7-a182-43eb-9d59-3cb6f4ae8912" />

  - Сделать файл доступным из интернета.

  Файл доступен по [ссылке](https://vladmgb-bucket-27102025.storage.yandexcloud.net/image.jpg)

<img width="1041" height="242" alt="image" src="https://github.com/user-attachments/assets/be1b72ae-1944-43e5-b6a2-7b9dce4e9f76" />

    
2. Создать группу ВМ в public подсети фиксированного размера с шаблоном LAMP и веб-страницей, содержащей ссылку на картинку из бакета:
- Создать Instance Group с тремя ВМ и шаблоном LAMP. Для LAMP рекомендуется использовать image_id = fd827b91d99psvq5fjit.
- Для создания стартовой веб-страницы рекомендуется использовать раздел user_data в meta_data.
- Разместить в стартовой веб-странице шаблонной ВМ ссылку на картинку из бакета.
- Настроить проверку состояния ВМ.

Группа ВМ создана:

<img width="862" height="495" alt="image" src="https://github.com/user-attachments/assets/3eb83fd2-f469-45dd-ac31-8215712ffd0a" />

<img width="1034" height="350" alt="image" src="https://github.com/user-attachments/assets/7d7e06b2-3e6f-42bb-84e8-b8306e0b0b23" />

<img width="1204" height="302" alt="image" src="https://github.com/user-attachments/assets/3a25fe24-0cb1-4694-9390-02df3d9ae260" />

Странички с картинкой доступны:
[http://158.160.123.3](http://158.160.123.3)
[http://84.201.159.30](http://84.201.159.30)
[http://89.169.153.249](http://89.169.153.249)


3. Подключить группу к сетевому балансировщику:
- Создать сетевой балансировщик.

<img width="1199" height="218" alt="image" src="https://github.com/user-attachments/assets/e65fbe8b-1c7a-46af-94f5-9bf6f0feb34f" />

<img width="830" height="579" alt="image" src="https://github.com/user-attachments/assets/385886f0-d65e-4c1a-969e-f66e95b6e266" />

Странички с картинкой через NLB доступна: [http://158.160.155.41](http://158.160.155.41)

- Проверить работоспособность, удалив одну или несколько ВМ.

Проверка

Удалена 1 ВМ.
<img width="692" height="493" alt="image" src="https://github.com/user-attachments/assets/703e3494-8fb9-4b30-914e-12e0fbc8e46d" />

Удалены 2 ВМ
<img width="632" height="497" alt="image" src="https://github.com/user-attachments/assets/6b0e5d51-2423-4156-b598-02e50291d42f" />

Страничка с картинкой через NLB все также доступна: [http://158.160.155.41](http://158.160.155.41)

- (дополнительно)* Создать Application Load Balancer с использованием Instance group и проверкой состояния.

