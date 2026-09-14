# Level Expansion 06

Este ciclo amplia o vertical slice com uma sequência de progressão em duas lojas, preservando o núcleo de combate e câmera.

## Novo fluxo

1. entrar na loja leste e encontrar o fusível;
2. levar o fusível ao painel elétrico;
3. restaurar a energia da loja;
4. a chave de serviço só aparece após a energia voltar;
5. atravessar para a loja oeste, pegar a chave e seguir ao portão norte;
6. destrancar o portão e concluir a área.

## Implementação

- `FusePickup` como item-chave reutilizável;
- `PowerPanel` com estado apagado/energizado;
- controlador `LevelExpansion06` desacoplado de `main.gd`;
- remoção diferida da chave original e respawn somente após o painel ser energizado;
- pequeno interior na loja leste com paredes, prateleiras, piso e entrada definida;
- luz interna que acende quando a energia é restaurada;
- objetivos do HUD atualizados a cada etapa.

## Arquitetura

O controlador é um filho da cena principal e instala a sequência após o `_ready` do nível. Isso evita continuar crescendo `main.gd` e permite que futuras áreas tenham controladores próprios.

## Validação

- import/parsing no Godot 4.3;
- smoke test headless da cena principal;
- chave não deve existir antes da energia ser restaurada;
- painel não deve energizar sem o fusível;
- fluxo anterior de chave → portão → conclusão permanece compatível.
