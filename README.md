# Night Shift Prototype

Protótipo original de survival horror 2.5D feito em **Godot 4**, inspirado na linguagem visual de jogos modernos que misturam cenário 3D, câmera isométrica e aparência pixelada/retrô.

> Este projeto não copia código, assets, personagens, mapas, história ou propriedade intelectual de *Holstin*. O objetivo é explorar técnicas semelhantes de apresentação e gameplay com identidade própria.

## O que já existe

- mundo 3D com iluminação dinâmica, sombras e neblina;
- render em baixa resolução para aparência retrô/pixelada;
- personagem `CharacterBody3D`;
- movimento relativo à câmera;
- corrida;
- câmera ortográfica com **8 ângulos**, girando em passos de 45°;
- mira com mouse;
- tiro por raycast;
- pente, munição reserva e recarga;
- vida/dano/morte;
- inimigos com detecção, perseguição e ataque;
- porta interativa;
- pickup de munição;
- HUD e prompts de interação;
- cenário greybox inicial iluminado.

## Controles

| Ação | Controle |
|---|---|
| Mover | WASD |
| Correr | Shift |
| Girar câmera | Q / E |
| Mirar | Botão direito do mouse |
| Atirar | Botão esquerdo do mouse |
| Recarregar | R |
| Interagir | F |

## Como executar

1. Instale Godot 4.3 ou superior.
2. Abra `project.godot` no editor.
3. Execute o projeto com `F6/F5`.

## Estrutura

```text
project.godot
scenes/
  main.tscn
scripts/
  main.gd
  player.gd
  enemy.gd
  door.gd
  ammo_pickup.gd
```

## Próximo ciclo recomendado

1. validar o protótipo dentro do Godot e corrigir qualquer incompatibilidade específica de versão;
2. substituir cápsulas/caixas por sprites ou modelos low-poly autorais;
3. implementar animação direcional de 8 lados;
4. melhorar sistema de mira para transição de exploração → combate;
5. adicionar hit reactions, áudio e partículas;
6. criar primeiro ambiente autoral (rua + interior explorável);
7. criar puzzle curto e objetivo de 5–10 minutos;
8. adicionar inventário e itens-chave;
9. configurar export Windows/Linux/Web conforme compatibilidade do renderer;
10. adicionar testes e CI para validação de import/headless.

## Quality bar do vertical slice

O primeiro vertical slice só deve ser considerado pronto quando tiver:

- 5–10 minutos de gameplay contínuo;
- câmera sem travamentos nos oito ângulos;
- combate legível e responsivo;
- pelo menos um interior e um exterior;
- uma interação/puzzle;
- um inimigo funcional;
- iluminação e pós-processamento consistentes;
- áudio ambiente e feedback de combate;
- zero erros de parser/runtime no Godot;
- build reproduzível.
