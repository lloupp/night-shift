# Gameplay Loop 04

Este ciclo transforma a arena técnica em um loop curto com começo, objetivo e conclusão.

## Fluxo

1. jogador inicia na rua com o objetivo de encontrar a chave de serviço;
2. explora o quarteirão, enfrenta ou evita os inimigos e encontra a chave;
3. o HUD atualiza o objetivo para o portão de serviço ao norte;
4. o portão permanece bloqueado sem a chave e informa o requisito;
5. com a chave, o portão abre e o vertical slice é marcado como concluído.

## Implementação

- inventário mínimo de itens-chave no jogador;
- pickup de chave interativo e autoral;
- portão de saída com estado bloqueado/desbloqueado e indicador luminoso;
- abertura central no limite norte do cenário;
- objetivo persistente no HUD;
- mensagem de conclusão do vertical slice;
- congelamento do combate após a conclusão para evitar estados incoerentes.

## Regras preservadas

- nenhuma dependência externa;
- sem alteração no dano, munição ou velocidades;
- interações continuam usando o mesmo grupo e tecla F;
- o sistema é genérico o suficiente para receber outros IDs de chave depois.

## Próximo passo

Expandir o percurso para uma sequência de 5–10 minutos com interior dedicado, segundo objetivo, cura, mais variação de inimigos e checkpoint/restart.
