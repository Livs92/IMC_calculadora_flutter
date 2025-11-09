# 🩺 BMI Calculator — Cálculo de IMC com Stateful Widget

## 📘 Sobre o Projeto

Este aplicativo foi desenvolvido em **Flutter** com o objetivo de calcular o **Índice de Massa Corporal (IMC)** de forma prática e interativa.  
O projeto utiliza **Stateful Widgets** para gerenciar o estado da tela, permitindo que os valores e o resultado do cálculo sejam atualizados dinamicamente, seguindo o protótipo proposto na atividade.

---

## 🧩 Funcionalidades

- 🧍‍♂️ **Seleção de gênero** (masculino ou feminino) com feedback visual.
- ⚖️ **Campos de entrada personalizados** para peso (kg) e altura (cm), com teclado numérico próprio.
- 🔢 **Cálculo dinâmico** do IMC pela fórmula:

_(a altura é convertida de cm para metros automaticamente)_

- 🧮 Exibição do **resultado e categoria**:
- _Underweight_, _Normal_, _Overweight_ ou _Obesity_, com cores indicativas.
- 🧭 **Animações suaves** entre telas usando `AnimatedSwitcher` e `PageRouteBuilder`.
- 🧠 **Validação de dados**: impede erros como campos vazios, altura zero ou valores fora do intervalo.
- ℹ️ **Modal informativo** com faixas de referência do IMC.
- 🧼 **Botão de reinício** para limpar os campos e refazer o cálculo.

---

## 🎨 Layout e Design

- Baseado no **protótipo fornecido** pela atividade.
- Interface minimalista e intuitiva, construída com **Material 3**.
- Paleta de cores derivada do `colorSchemeSeed` (`#1E6C86`).
- Totalmente **responsiva**, adaptando-se a diferentes tamanhos de tela.

---

## 🧠 Tecnologias Utilizadas

| Tecnologia                         | Descrição                       |
| ---------------------------------- | ------------------------------- |
| **Flutter**                        | Framework principal             |
| **Dart**                           | Linguagem de programação        |
| **Material Design 3**              | Design system utilizado         |
| **Stateful Widgets**               | Controle do estado da aplicação |
| **Form Validation**                | Validação de entradas           |
| **BottomSheet & AnimatedSwitcher** | Animações e transições          |

---

## 🚀 Como Executar

1. Certifique-se de ter o **Flutter SDK** instalado.
2. Clone o repositório:

```bash
git clone https://github.com/Livs92/IMC_calculadora_flutter.git
```
