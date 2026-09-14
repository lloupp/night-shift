# Implementação inicial

## Objetivo

Entregar um vertical slice autoral de survival horror 2.5D em Godot 4, com câmera ortográfica rotativa, exploração, combate, interação e atmosfera retrô.

## Estado atual

O bootstrap inclui:

- personagem 3D com movimento relativo à câmera;
- corrida, mira, tiro, recarga, vida e munição;
- câmera ortográfica em oito ângulos de 45 graus;
- cenário greybox com colisões, iluminação e neblina;
- inimigos com detecção, perseguição e ataque;
- porta interativa e pickup de munição;
- HUD e feedback textual;
- CI headless com Godot 4.3 para import/parsing e smoke test.

## Restrições

- não reutilizar assets, mapas, personagens, nomes, código ou história de Holstin;
- manter a identidade visual e narrativa próprias;
- priorizar gameplay verificável antes de produção de arte definitiva;
- não aceitar parser/runtime errors no branch principal.

## Próximos ciclos

1. estabilizar CI e corrigir qualquer incompatibilidade encontrada pelo Godot real;
2. criar controlador de câmera com oclusão e transições mais suaves;
3. adicionar hit reaction, muzzle flash, áudio e feedback de dano;
4. criar um exterior e um interior autorais conectados;
5. adicionar inventário, item-chave e puzzle curto;
6. substituir greybox por direção de arte 2.5D autoral;
7. preparar export Web e desktop quando o vertical slice estiver estável.
