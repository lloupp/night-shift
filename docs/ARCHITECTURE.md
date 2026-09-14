# Arquitetura inicial

`main.gd` compõe o greybox, câmera, HUD e objetos do protótipo. `player.gd` concentra movimento e estado de combate. `enemy.gd` implementa o perseguidor básico. `door.gd` e `ammo_pickup.gd` são interactables independentes.

A próxima refatoração deve separar composição de cenário, câmera e HUD em cenas/scripts próprios antes de o vertical slice crescer.
