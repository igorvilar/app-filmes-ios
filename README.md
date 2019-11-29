# app-filmes-ios

- Foi desenvolvido o app utilizando Swift, usando padrão da apple mvc, caso eu fosse desenvolver um projeto de grande porte optaria por usar a mvvm como padrão, pois permitiria testar todas as camadas de forma independente.

- Em vez de usar componente reconhecido do mercado, como "Alamofire" para fazer as requisições a api, optei for criar minha classe de service como faço em projetos pessoais, caso fosse um projeto em Android, não teria dúvida de usar o Retrofit, mesmo sendo projeto um projeto de pequeno porte.

- Não cheguei a fazer os testes unitários, mas caso fosse fazer para esse app, is teste principalmente a camada de repository criada por mim.

- Em relação a Animação optei por usar um componente de terceiros de qualidade reconhecida para fazer uma animação na tela splash

- Em relação a teste automatizado, cheguei gravar um teste da navegação do app usando ferramenta de gravação da própria apple, salvar raiz do projeto a gravação do teste.

- Em relação ao banco de dados local, optei por usar o core data, padrão do iOS e criei uma banco uma tabela de comentários salvas local, só para demonstrar a funcionalidade, em que na tela de detalhes o usuário pode comentar sobre os filmes individualmente e salva direto no banco de dados local, os comentários não listados na própria tela de detalhes, não tive muito tempo para trabalhar no layout dessa funcionalidade, acabei por fazer da maneira mais simples possível em relação ao layout.


