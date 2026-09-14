# Survival Loop 05

Este ciclo melhora a sobrevivência e torna o vertical slice imediatamente rejogável.

## Entregas

- kit médico interativo que só é consumido quando há vida a recuperar;
- HUD de vida em estado crítico abaixo de 30%;
- reinício da cena com Enter após morte ou conclusão;
- congelamento dos inimigos em estados finais;
- terceiro arquétipo de ameaça, o Hunter;
- Hunter mais rápido, com menor vida, maior alcance de detecção e paleta azul própria;
- suporte de paleta parametrizada na classe base dos inimigos.

## Intenção de design

O Stalker continua sendo a ameaça previsível e resistente. O Hunter pressiona deslocamento e priorização de alvo, criando uma decisão real entre gastar munição, fugir ou procurar o kit médico.

## Regras preservadas

- dano base dos ataques permanece inalterado;
- o jogador mantém as mesmas velocidades e capacidade de munição;
- o loop de chave/portão permanece intacto;
- nenhuma dependência ou asset externo foi adicionado.

## Validação

- import/parsing no Godot 4.3;
- execução headless da cena principal;
- morte e vitória devem aceitar reinício;
- kit médico não deve ser consumido com vida cheia;
- Hunter usa a mesma lógica de IA, evitando duplicação de comportamento.
