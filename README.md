# 📘 TCC — Recomendação Sensorial de Cervejas com Julia 🍺

Este repositório contém o código-fonte em **LaTeX** e **Julia** referente ao **Trabalho de Conclusão de Curso** de José Eduardo Quicoli Fonseca, intitulado:

> **"Desenvolvimento de um Algoritmo de Recomendação de Cervejas Personalizadas Utilizando a Linguagem Julia"**

O trabalho foi apresentado como requisito para obtenção do grau de Engenheiro de Produção pela Universidade Federal Fluminense (UFF), sob orientação do Prof. Dr. Artur Alves Pessoa.

---

## 📂 Estrutura do Repositório

```bash
TCC---Recomenda-o-Sensorial-de-Cervejas/
│
├── latex/                   # Arquivos LaTeX da monografia
│   ├── TCC.tex              # Documento principal
│   ├── capítulos/           # Seções divididas (introdução, metodologia, etc.)
│   └── imagens/             # Figuras, tabelas e gráficos
│
├── beer_recommender/       # Código-fonte do sistema em Julia
│   ├── main.jl              # Execução principal
│   ├── BeerData.jl          # Módulo de carregamento e parsing de dados
│   ├── solve_p_median.jl    # Algoritmo de clusterização p-mediana
│   └── data/                # Base de dados BJCP e arquivos `.tex` por estilo
│
└── README.md                # Este documento
🧠 Objetivo do Projeto
Desenvolver um sistema de recomendação de estilos de cerveja baseado em atributos físico-químicos e sensoriais, utilizando a linguagem de programação Julia e dados do guia BJCP 2015.

⚙️ Tecnologias Utilizadas
Julia 1.9+

DataFrames.jl

CSV.jl

JuMP.jl + GLPK.jl (p-mediana)

Unicode.jl (limpeza textual)

LaTeX

ABNTex2 / UTFPR / customização completa para monografias acadêmicas

🧪 Funcionalidades do Sistema
Leitura automatizada de arquivos CSV e LaTeX por estilo de cerveja

Tratamento e imputação de dados ausentes

Extração de descrições técnicas e sensoriais dos estilos

Algoritmo de recomendação baseado em similaridade de perfil

Clusterização de estilos por proximidade (p-mediana)

Geração de gráficos e tabelas para análise e visualização

📊 Dados Utilizados
2015_Guidelines_numbers_OK.csv: versão estruturada da base BJCP com atributos numéricos e textuais

Pastas por estilo contendo .tex com descrições sensoriais, históricas e técnicas

🧾 Como Executar o Projeto
Instale Julia 1.9+ e os pacotes necessários:

julia
Copiar
Editar
import Pkg
Pkg.add(["CSV", "DataFrames", "Statistics", "JuMP", "GLPK", "Unicode"])
Execute o sistema:

julia
Copiar
Editar
include("beer_recommender/main.jl")
Compile a monografia em LaTeX:

bash
Copiar
Editar
cd latex
pdflatex TCC.tex
bibtex TCC
pdflatex TCC.tex
pdflatex TCC.tex
👨‍🎓 Autor
José Eduardo Quicoli Fonseca
Engenharia de Produção — Universidade Federal Fluminense
Orientador: Prof. Dr. Artur Alves Pessoa

📄 Licença
Este repositório é de uso acadêmico e pode ser utilizado como base para fins educacionais e de pesquisa, mediante citação adequada.

📬 Contato
Para dúvidas ou colaborações:

LinkedIn

E-mail

yaml
Copiar
Editar
