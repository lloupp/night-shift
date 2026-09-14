# Visual Pass 02

Este ciclo aproxima o protótipo da linguagem survival horror 2.5D sem copiar assets, mapas, personagens ou conteúdo de terceiros.

## Entregas

- câmera ortográfica com seguimento amortecido;
- rotação em oito passos de 45 graus;
- oclusão automática de paredes entre câmera e personagem, sem desativar colisões;
- personagem low-poly com silhueta mais legível e rotação quantizada em oito direções;
- inimigos com a mesma leitura direcional;
- animação procedural simples de caminhada;
- rua mais definida com pista, calçadas, fachadas, sinalização, objetos e pontos de luz;
- HUD com indicação do ângulo atual da câmera;
- manutenção do render interno em baixa resolução e nearest filtering.

## Critérios de validação

- importar no Godot 4.3 sem erro;
- executar a cena principal em headless sem erro de parser/runtime;
- preservar combate, porta, pickup e movimentação;
- garantir que a oclusão altere somente visibilidade, não a física;
- manter funcionalidade nos oito ângulos de câmera.

## Próximo passe

Depois deste ciclo, o salto de qualidade mais relevante será trocar os proxies procedurais por arte autoral dedicada: personagem/sprites ou modelos estilizados, materiais de cenário, decals, partículas, áudio e composição de uma área explorável de 5–10 minutos.
