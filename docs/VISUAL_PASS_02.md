# Visual Pass 02

Este ciclo aproxima o protótipo da linguagem survival horror 2.5D sem copiar assets ou conteúdo de terceiros.

Metas técnicas:

- câmera ortográfica com seguimento amortecido e rotação em 8 passos;
- oclusão automática de paredes entre câmera e personagem;
- silhueta low-poly direcional com rotação quantizada em 8 direções;
- cenário mais legível como rua/interior, com calçada, fachada, balcão, beco e iluminação localizada;
- HUD com indicação do ângulo da câmera;
- manutenção do render interno de baixa resolução e nearest filtering.

Critérios de validação:

- projeto importa no Godot 4.3 sem erro;
- cena principal executa em headless sem erro de parser/runtime;
- colisões permanecem independentes da visibilidade usada para oclusão;
- câmera e personagem continuam funcionais nos oito ângulos.
