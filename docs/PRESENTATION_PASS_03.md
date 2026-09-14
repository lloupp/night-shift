# Presentation Pass 03

Este ciclo melhora feedback de combate e atmosfera sem adicionar dependências externas ou alterar as regras centrais do protótipo.

## Entregas

- muzzle flash procedural no disparo;
- flash de impacto diferenciado para cenário e inimigos;
- hit flash no corpo dos inimigos;
- burst visual na morte do inimigo;
- camera shake com intensidade separada para disparo, acerto e dano recebido;
- overlay vermelho de dano no HUD;
- feedback temporário no crosshair ao disparar;
- luzes de ambiente com flicker controlado;
- posição explícita do cano da arma no jogador;
- sinais de dano e morte para desacoplar gameplay dos efeitos visuais.

## Restrições preservadas

- combate continua por raycast;
- munição, recarga e dano não foram rebalanceados;
- colisões e oclusão de câmera permanecem independentes dos efeitos;
- nenhum asset externo foi incluído;
- todos os efeitos são construídos com recursos nativos do Godot 4.3.

## Validação

- import/parsing no Godot 4.3;
- smoke test headless da cena principal;
- nenhum efeito deve impedir gameplay caso seja removido;
- feedback visual deve ser curto e não esconder o jogador.
