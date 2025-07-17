-- Bloco de Código: Criação da Tabela Usuario
-- Descrição: Armazena os dados comuns a todos os usuários do sistema, como
-- alunos e professores.
-- Justificativa das Decisões:
-- - `id` é a chave primária para identificação única.
-- - `email` é definido como UNIQUE para garantir que não existam dois
-- usuários com o mesmo e-mail.
-- - `status` e `data_cadastro` são NOT NULL para garantir que todo usuário
-- tenha um estado e uma data de registro.
CREATE TABLE Usuario (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    status_usuario VARCHAR(50) NOT NULL,
    ultimo_acesso TIMESTAMP,
    data_cadastro DATE NOT NULL
);

-- Bloco de Código: Criação da Tabela Instituicao
-- Descrição: Armazena informações sobre as instituições de ensino
-- parceiras.
-- Justificativa das Decisões:
-- - `cnpj` é UNIQUE para garantir a unicidade de cada instituição.
-- - `email` também é UNIQUE para fins de contato.
CREATE TABLE Instituicao (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    tipo_instituicao VARCHAR(50),
    status_instituicao VARCHAR(50) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefone VARCHAR(20)
);

-- Bloco de Código: Criação da Tabela Endereco
-- Descrição: Armazena os dados de endereço das instituições.
--Relacionamento 1:1 com Instituicao.
-- Justificativa das Decisões:
-- - A chave primária `id_instituicao` é também uma chave estrangeira para
-- `Instituicao`, caracterizando um relacionamento de um para um.
CREATE TABLE Endereco (
    id_instituicao INT PRIMARY KEY,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(50) NOT NULL,
    logradouro VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_instituicao) REFERENCES Instituicao(id) ON DELETE CASCADE
);

-- Bloco de Código: Criação da Tabela Professor
-- Descrição: Especialização da tabela Usuario, contendo dados específicos
-- de professores.
-- Justificativa das Decisões:
-- - `id_usuario` é a chave primária e estrangeira, estabelecendo a relação
-- de "é um" com Usuario.
-- - `registro` é UNIQUE para garantir um número de registro funcional
-- único por professor.
CREATE TABLE Professor (
    id_usuario INT PRIMARY KEY,
    registro VARCHAR(50) NOT NULL UNIQUE,
    area_atuacao VARCHAR(100),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id) ON DELETE CASCADE
);

-- Bloco de Código: Criação da Tabela Incentivo
-- Descrição: Armazena os diferentes tipos de incentivos (bolsas,
-- descontos) que podem ser concedidos aos alunos.
CREATE TABLE Incentivo (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    status_incentivo VARCHAR(50) NOT NULL,
    tipo VARCHAR(100) NOT NULL,
    origem VARCHAR(100),
    valor DECIMAL(10, 2),
    data_concessao DATE,
    data_vencimento DATE
);

-- Bloco de Código: Criação da Tabela Aluno
-- Descrição: Especialização da tabela Usuario, com informações específicas
-- de alunos.
-- Justificativa das Decisões: -- - `id_usuario` é a chave primária e
-- estrangeira, conectando-se a Usuario`.
-- - `matricula` é UNIQUE para garantir que cada aluno tenha um número de
-- matrícula exclusivo.
-- - `id_incentivo` é uma chave estrangeira opcional (pode ser NULL).
CREATE TABLE Aluno (
    id_usuario INT PRIMARY KEY,
    id_incentivo INT,
    matricula VARCHAR(50) NOT NULL UNIQUE,
    data_ingresso DATE NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (id_incentivo) REFERENCES Incentivo(id) ON DELETE SET NULL
);

-- Bloco de Código: Criação da Tabela Ocorrencia
-- Descrição: Registra ocorrências (acadêmicas, disciplinares) relacionadas
-- a um aluno, abertas por um professor.
CREATE TABLE Ocorrencia (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_professor INT NOT NULL,
    status_ocorrencia VARCHAR(50) NOT NULL,
    tipo_ocorrencia VARCHAR(100) NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    data_ocorrencia DATE NOT NULL,
    FOREIGN KEY (id_professor) REFERENCES Professor(id_usuario) ON DELETE CASCADE
);

-- Bloco de Código: Criação da Tabela Recebe (associativa)
-- Descrição: Tabela associativa que liga um aluno a uma ocorrência.
-- Justificativa das Decisões:
-- - A chave primária é composta por `id_aluno` e `id_ocorrencia` para
-- garantir que um aluno não possa ser associado à mesma ocorrência mais de uma
-- vez.
CREATE TABLE Recebe (
    id_aluno INT NOT NULL,
    id_ocorrencia INT NOT NULL,
    PRIMARY KEY (id_aluno, id_ocorrencia),
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_ocorrencia) REFERENCES Ocorrencia(id) ON DELETE CASCADE
);

-- Bloco de Código: Criação da Tabela Conteudo
-- Descrição: Armazena os conteúdos (vídeos, artigos, etc.) que podem ser
-- utilizados nas disciplinas.
CREATE TABLE Conteudo (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    tipo VARCHAR(50) NOT NULL,
    URL VARCHAR(255),
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    data_publicacao DATE,
    visibilidade VARCHAR(50)
);

-- Bloco de Código: Criação da Tabela Disciplina
-- Descrição: Armazena as informações das disciplinas oferecidas pelas
-- instituições.
CREATE TABLE Disciplina (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_conteudo INT,
    id_instituicao INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    ementa TEXT,
    objetivos TEXT,
    bibliografia TEXT,
    carga_horaria INT,
    FOREIGN KEY (id_conteudo) REFERENCES Conteudo(id) ON DELETE SET NULL,
    FOREIGN KEY (id_instituicao) REFERENCES Instituicao(id) ON DELETE CASCADE
);

-- Bloco de Código: Criação da Tabela Forum
-- Descrição: Tabela para os fóruns de discussão, que podem ser associados
-- a turmas.
CREATE TABLE Forum (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    titulo VARCHAR(255) NOT NULL,
    status_forum VARCHAR(50) NOT NULL,
    data_criacao TIMESTAMP NOT NULL
);

-- Bloco de Código: Criação da Tabela Turma
-- Descrição: Define as turmas de cada disciplina, com professor, vagas e
-- horários.
-- Justificativa das Decisões:
-- - Adicionada uma restrição `CHECK` para garantir que as vagas
-- disponíveis não ultrapassem as vagas totais.
CREATE TABLE Turma (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_professor INT NOT NULL,
    id_disciplina INT NOT NULL,
    id_forum INT UNIQUE,
    status_turma VARCHAR(50) NOT NULL,
    vagas_disp INT,
    vagas_totais INT,
    local VARCHAR(100),
    horario VARCHAR(100),
    ano INT NOT NULL,
    semestre INT NOT NULL,
    FOREIGN KEY (id_professor) REFERENCES Professor(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_disciplina) REFERENCES Disciplina(id) ON DELETE CASCADE,
    FOREIGN KEY (id_forum) REFERENCES Forum(id) ON DELETE SET NULL,
    CHECK (vagas_disp <= vagas_totais)
);

-- Bloco de Código: Criação da Tabela Aluno_Turma (associativa)
-- Descrição: Tabela associativa que matricula um aluno em uma turma e
-- armazena seu desempenho.
-- Justificativa das Decisões:
-- - Chave primária composta por `id_aluno` e `id_turma`.
-- - `nota_final` e `frequencia` possuem restrições `CHECK` para manter os
-- valores dentro de um intervalo válido.
CREATE TABLE Aluno_Turma (
    id_aluno INT NOT NULL,
    id_turma INT NOT NULL,
    status_inscricao VARCHAR(50),
    data_inscricao DATE,
    frequencia DECIMAL(5, 2),
    nota_final DECIMAL(4, 2),
    PRIMARY KEY (id_aluno, id_turma),
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_turma) REFERENCES Turma(id) ON DELETE CASCADE,
    CHECK (nota_final >= 0.00 AND nota_final <= 10.00),
    CHECK (frequencia >= 0.00 AND frequencia <= 100.00)
);

-- Bloco de Código: Criação da Tabela Mensagem
-- Descrição: Armazena as mensagens trocadas dentro de um fórum.
CREATE TABLE Mensagem (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_forum INT NOT NULL,
    titulo VARCHAR(255),
    corpo TEXT NOT NULL,
    resolvido BOOLEAN,
    data TIMESTAMP NOT NULL,
    FOREIGN KEY (id_forum) REFERENCES Forum(id) ON DELETE CASCADE
);

-- Bloco de Código: Criação da Tabela Certificado
-- Descrição: Armazena os certificados emitidos para os alunos na conclusão
-- de cursos/disciplinas.
-- Justificativa das Decisões:
-- - `codigo_validacao` é UNIQUE para permitir a verificação de
-- autenticidade do certificado.
CREATE TABLE Certificado (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    codigo_validacao VARCHAR(255) NOT NULL UNIQUE,
    id_aluno INT NOT NULL,
    assinatura_digital VARCHAR(255),
    carga_horaria INT NOT NULL,
    data_conclusao DATE NOT NULL,
    nota_final DECIMAL(4, 2),
    data_emissao DATE NOT NULL,
    FOREIGN KEY (id_aluno) REFERENCES Aluno(id_usuario) ON DELETE CASCADE
);

-- Demais tabelas do diagrama (Avaliacao, Material_Educacional, Curso)
-- Adicionadas para completar o esquema conforme o mapeamento.
CREATE TABLE Curso (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_instituicao INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    carga_horaria INT,
    FOREIGN KEY (id_instituicao) REFERENCES Instituicao(id) ON DELETE CASCADE
);

CREATE TABLE Avaliacao (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_turma INT NOT NULL,
    status_avaliacao VARCHAR(50),
    descricao TEXT,
    titulo VARCHAR(255) NOT NULL,
    tipo_avaliacao VARCHAR(50),
    peso DECIMAL(3,2),
    tempo_limite INT,
    data_fechamento TIMESTAMP,
    data_abertura TIMESTAMP,
    nota DECIMAL(4,2),
    FOREIGN KEY (id_turma) REFERENCES Turma(id) ON DELETE CASCADE,
    CHECK (peso >= 0.00 AND peso <= 1.00),
    CHECK (nota >= 0.00 AND nota <= 10.00)
);

CREATE TABLE Material_Educacional (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(50),
    lote VARCHAR(50),
    quantidade INT,
    data_entrega DATE,
    data_validade DATE
);

-- Índice 1: Índice no campo "email" da tabela Usuario
-- índice melhora performance de buscas por e-mail (login/autenticação, por
-- exemplo).
CREATE INDEX idx_usuario_email ON Usuario(email);

-- Índice 2: Índice no campo "id_instituicao" da tabela Disciplina
-- Otimiza consultas por disciplinas de uma instituição, que são comuns em
-- relatórios e exibições por instituição.
CREATE INDEX idx_disciplina_id_instituicao ON Disciplina(id_instituicao);

-- Índice 3: Índice no campo "id_professor" da tabela Turma
-- Índice ajuda a acelerar esses filtros.
CREATE INDEX idx_turma_id_professor ON Turma(id_professor);

-- Índice 4: Índice no campo "status_turma" da tabela Turma
-- Suporte a filtros frequentes por status (ex: “ativa”, “encerrada”, etc),
-- especialmente em dashboards.
CREATE INDEX idx_turma_status ON Turma(status_turma);

-- Índice 5: Índice composto em Aluno_Turma (id_turma, status_inscricao)
-- Permite acelerar consultas que listam alunos inscritos em uma turma com
-- determinado status.
CREATE INDEX idx_aluno_turma_turma_status ON Aluno_Turma(id_turma, status_inscricao);

-- Índice 6: Índice no campo "matricula" da tabela Aluno
-- melhora desempenho em buscas por matrícula, muito comum em sistemas
-- acadêmicos.
CREATE INDEX idx_aluno_matricula ON Aluno(matricula);

-- Índice 7: Índice no campo "data_ocorrencia" da tabela Ocorrencia
-- acelera buscas por ocorrências em períodos específicos.
CREATE INDEX idx_ocorrencia_data ON Ocorrencia(data_ocorrencia);

INSERT INTO Usuario (nome, email, senha, status_usuario, ultimo_acesso, data_cadastro) VALUES
('Ana Silva', 'ana@exemplo.com', 'senhaAna', 'ativo', NOW(), '2023-01-15'),
('Bruno Souza', 'bruno@exemplo.com', 'senhaBruno', 'ativo', NOW(), '2023-01-16'),
('Carla Mendes', 'carla@exemplo.com', 'senhaCarla', 'ativo', NOW(), '2023-01-17'),
('Daniel Alves', 'daniel@exemplo.com', 'senhaDaniel', 'ativo', NOW(), '2023-01-18'),
('Eduarda Lima', 'eduarda@exemplo.com', 'senhaEduarda', 'ativo', NOW(), '2023-01-19'),
('Fabio Costa', 'fabio@exemplo.com', 'senhaFabio', 'ativo', NOW(), '2023-01-20'),
('Gabriela Reis', 'gabriela@exemplo.com', 'senhaGabriela', 'ativo', NOW(), '2023-01-21'),
('Hugo Martins', 'hugo@exemplo.com', 'senhaHugo', 'ativo', NOW(), '2023-01-22'),
('Isabela Nunes', 'isabela@exemplo.com', 'senhaIsabela', 'ativo', NOW(), '2023-01-23'),
('João Pedro', 'joao@exemplo.com', 'senhaJoao', 'ativo', NOW(), '2023-01-24'),
('Lucas Braga', 'lucas@exemplo.com', 'senhaLucas', 'ativo', NOW(), '2023-01-25'),
('Marina Pires', 'marina@exemplo.com', 'senhaMarina', 'ativo', NOW(), '2023-01-26'),
('Nicolas Araújo', 'nicolas@exemplo.com', 'senhaNicolas', 'ativo', NOW(), '2023-01-27'),
('Olívia Lemos', 'olivia@exemplo.com', 'senhaOlivia', 'ativo', NOW(), '2023-01-28'),
('Pedro Nunes', 'pedro@exemplo.com', 'senhaPedro', 'ativo', NOW(), '2023-01-29'),
('Quesia Duarte', 'quesia@exemplo.com', 'senhaQuesia', 'ativo', NOW(), '2023-01-30'),
('Rafael Couto', 'rafael@exemplo.com', 'senhaRafael', 'ativo', NOW(), '2023-01-31'),
('Sara Tavares', 'sara@exemplo.com', 'senhaSara', 'ativo', NOW(), '2023-02-01'),
('Tiago Andrade', 'tiago@exemplo.com', 'senhaTiago', 'ativo', NOW(), '2023-02-02'),
('Úrsula Moreira', 'ursula@exemplo.com', 'senhaUrsula', 'ativo', NOW(), '2023-02-03');

INSERT INTO Professor (id_usuario, registro, area_atuacao) VALUES
(1, 'REG123', 'Engenharia de Software'),
(2, 'REG124', 'Ciência da Computação'),
(3, 'REG125', 'Matemática'),
(4, 'REG126', 'Física'),
(5, 'REG127', 'Química'),
(6, 'REG128', 'Administração'),
(7, 'REG129', 'Direito'),
(8, 'REG130', 'Educação Física'),
(9, 'REG131', 'Arquitetura'),
(10, 'REG132', 'Biologia');

INSERT INTO Incentivo (status_incentivo, tipo, origem, valor, data_concessao, data_vencimento) VALUES
('ativo', 'bolsa', 'federal', 1000.00, '2023-01-01', '2023-12-31'),
('ativo', 'desconto', 'institucional', 500.00, '2023-01-01', '2023-12-31'),
('ativo', 'bolsa', 'estadual', 800.00, '2023-01-01', '2023-12-31'),
('ativo', 'desconto', 'municipal', 300.00, '2023-01-01', '2023-12-31'),
('ativo', 'bolsa', 'privada', 1200.00, '2023-01-01', '2023-12-31'),
('ativo', 'desconto', 'federal', 700.00, '2023-01-01', '2023-12-31'),
('ativo', 'bolsa', 'institucional', 1500.00, '2023-01-01', '2023-12-31'),
('ativo', 'desconto', 'estadual', 600.00, '2023-01-01', '2023-12-31'),
('ativo', 'bolsa', 'municipal', 1100.00, '2023-01-01', '2023-12-31'),
('ativo', 'desconto', 'privada', 400.00, '2023-01-01', '2023-12-31');

INSERT INTO Aluno (id_usuario, id_incentivo, matricula, data_ingresso) VALUES
(11, 1, '20230011', '2023-02-01'),
(12, 2, '20230012', '2023-02-02'),
(13, 3, '20230013', '2023-02-03'),
(14, 4, '20230014', '2023-02-04'),
(15, 5, '20230015', '2023-02-05'),
(16, 6, '20230016', '2023-02-06'),
(17, 7, '20230017', '2023-02-07'),
(18, 8, '20230018', '2023-02-08'),
(19, 9, '20230019', '2023-02-09'),
(20, 10, '20230020', '2023-02-10');

INSERT INTO Instituicao (nome, cnpj, tipo_instituicao, status_instituicao, email, telefone) VALUES
('Universidade Federal', '00.000.000/0001-00', 'Pública', 'Ativa', 'contato@uf.com', '123456789'),
('Instituto Técnico', '11.111.111/0001-11', 'Privada', 'Ativa', 'info@it.com', '987654321'),
('Faculdade XYZ', '22.222.222/0001-22', 'Privada', 'Ativa', 'contato@xyz.com', '192837465'),
('Centro de Ensino ABC', '33.333.333/0001-33', 'Pública', 'Ativa', 'abc@centro.com', '564738291'),
('Instituto Superior DEF', '44.444.444/0001-44', 'Privada', 'Ativa', 'def@instituto.com', '857493020'),
('Universidade GHI', '55.555.555/0001-55', 'Pública', 'Ativa', 'ghi@uni.com', '123123123'),
('Faculdade JKL', '66.666.666/0001-66', 'Privada', 'Ativa', 'jkl@faculdade.com', '321321321'),
('Instituto MNO', '77.777.777/0001-77', 'Privada', 'Ativa', 'mno@instituto.com', '456456456'),
('Universidade PQR', '88.888.888/0001-88', 'Pública', 'Ativa', 'pqr@uni.com', '654654654'),
('Faculdade STU', '99.999.999/0001-99', 'Privada', 'Ativa', 'stu@faculdade.com', '789789789');

INSERT INTO Endereco (id_instituicao, cidade, estado, logradouro) VALUES
(1, 'São Carlos', 'SP', 'Rua das Flores, 123'),
(2, 'Campinas', 'SP', 'Av. Brasil, 456'),
(3, 'Ribeirão Preto', 'SP', 'Rua da Paz, 789'),
(4, 'Araraquara', 'SP', 'Rua Bento de Abreu, 101'),
(5, 'Sorocaba', 'SP', 'Av. Independência, 202'),
(6, 'Bauru', 'SP', 'Rua XV de Novembro, 303'),
(7, 'Piracicaba', 'SP', 'Rua do Porto, 404'),
(8, 'Limeira', 'SP', 'Av. Paulista, 505'),
(9, 'Jundiaí', 'SP', 'Rua das Palmeiras, 606'),
(10, 'São Paulo', 'SP', 'Rua Augusta, 707');

INSERT INTO Conteudo (tipo, URL, titulo, descricao, data_publicacao, visibilidade) VALUES
('video', 'https://youtu.be/video1', 'Introdução à Engenharia', 'Video introdutório sobre engenharia.', '2023-01-10', 'publico'),
('artigo', 'https://site.com/artigo1', 'Algoritmos Básicos', 'Artigo sobre algoritmos.', '2023-01-15', 'publico'),
('video', 'https://youtu.be/video2', 'Cálculo 1', 'Video sobre cálculo diferencial.', '2023-02-01', 'privado'),
('artigo', 'https://site.com/artigo2', 'Estatística Aplicada', 'Artigo sobre estatística.', '2023-02-10', 'publico'),
('video', 'https://youtu.be/video3', 'Programação em C', 'Video aula de programação.', '2023-02-15', 'publico'),
('artigo', 'https://site.com/artigo3', 'Banco de Dados', 'Artigo sobre SQL.', '2023-02-20', 'privado'),
('video', 'https://youtu.be/video4', 'Redes de Computadores', 'Video sobre redes.', '2023-02-25', 'publico'),
('artigo', 'https://site.com/artigo4', 'Engenharia de Software', 'Artigo sobre engenharia.', '2023-03-01', 'publico'),
('video', 'https://youtu.be/video5', 'Sistemas Operacionais', 'Video sobre SO.', '2023-03-05', 'privado'),
('artigo', 'https://site.com/artigo5', 'Segurança da Informação', 'Artigo sobre segurança.', '2023-03-10', 'publico');

INSERT INTO Disciplina (id_conteudo, id_instituicao, nome, ementa, objetivos, bibliografia, carga_horaria) VALUES
(1, 1, 'Engenharia de Software I', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro A, Livro B', 60),
(2, 2, 'Algoritmos e Estruturas de Dados', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro C, Livro D', 60),
(3, 3, 'Cálculo I', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro E, Livro F', 60),
(4, 4, 'Administração Geral', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro G, Livro H', 60),
(5, 5, 'Pedagogia', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro I, Livro J', 60),
(6, 6, 'Arquitetura', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro K, Livro L', 60),
(7, 7, 'Matemática Aplicada', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro M, Livro N', 60),
(8, 8, 'Educação Física', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro O, Livro P', 60),
(9, 9, 'Direito Constitucional', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro Q, Livro R', 60),
(10, 10, 'Design Gráfico', 'Ementa da disciplina', 'Objetivos da disciplina', 'Livro S, Livro T', 60);

INSERT INTO Forum (titulo, status_forum, data_criacao) VALUES
('Forum de Engenharia', 'ativo', NOW()),
('Forum de Computação', 'ativo', NOW()),
('Forum de Matemática', 'ativo', NOW()),
('Forum de Administração', 'ativo', NOW()),
('Forum de Pedagogia', 'ativo', NOW()),
('Forum de Arquitetura', 'ativo', NOW()),
('Forum de Educação Física', 'ativo', NOW()),
('Forum de Direito', 'ativo', NOW()),
('Forum de Design', 'ativo', NOW()),
('Forum Geral', 'ativo', NOW());

INSERT INTO Turma (id_professor, id_disciplina, id_forum, status_turma, vagas_disp, vagas_totais, local, horario, ano, semestre) VALUES
(1, 1, 1, 'ativa', 30, 40, 'Sala 101', '08:00-10:00', 2023, 1),
(2, 2, 2, 'ativa', 25, 35, 'Sala 102', '10:00-12:00', 2023, 1),
(3, 3, 3, 'ativa', 20, 30, 'Sala 103', '14:00-16:00', 2023, 1),
(4, 4, 4, 'ativa', 15, 25, 'Sala 104', '08:00-10:00', 2023, 1),
(5, 5, 5, 'ativa', 10, 20, 'Sala 105', '10:00-12:00', 2023, 1),
(6, 6, 6, 'ativa', 30, 40, 'Sala 106', '14:00-16:00', 2023, 1),
(7, 7, 7, 'ativa', 25, 35, 'Sala 107', '08:00-10:00', 2023, 1),
(8, 8, 8, 'ativa', 20, 30, 'Sala 108', '10:00-12:00', 2023, 1),
(9, 9, 9, 'ativa', 15, 25, 'Sala 109', '14:00-16:00', 2023, 1),
(10, 10, 10, 'ativa', 10, 20, 'Sala 110', '08:00-10:00', 2023, 1);

INSERT INTO Ocorrencia (id_professor, status_ocorrencia, tipo_ocorrencia, titulo, descricao, data_ocorrencia) VALUES
(1, 'aberta', 'acadêmica', 'Falta em aula', 'Aluno faltou em 3 aulas consecutivas.', '2023-03-01'),
(2, 'aberta', 'disciplinar', 'Comportamento inadequado', 'Aluno desrespeitou professor.', '2023-03-02'),
(3, 'fechada', 'acadêmica', 'Entrega atrasada', 'Aluno entregou trabalho atrasado.', '2023-03-03'),
(4, 'aberta', 'disciplinar', 'Uso de celular', 'Aluno usou celular durante a aula.', '2023-03-04'),
(5, 'fechada', 'acadêmica', 'Participação', 'Aluno não participou das atividades.', '2023-03-05'),
(6, 'aberta', 'acadêmica', 'Prova não realizada', 'Aluno não compareceu à prova.', '2023-03-06'),
(7, 'fechada', 'disciplinar', 'Atraso', 'Aluno chegou atrasado.', '2023-03-07'),
(8, 'aberta', 'acadêmica', 'Revisão de nota', 'Aluno solicitou revisão.', '2023-03-08'),
(9, 'fechada', 'disciplinar', 'Uso de linguagem inadequada', 'Aluno usou linguagem inadequada.', '2023-03-09'),
(10, 'aberta', 'acadêmica', 'Falta de material', 'Aluno esqueceu material para aula.', '2023-03-10');

INSERT INTO Curso (id_instituicao, nome, descricao, carga_horaria) VALUES
(1, 'Engenharia de Software', 'Curso de graduação em Engenharia de Software', 3600),
(2, 'Ciência da Computação', 'Curso de graduação em Ciência da Computação', 3600),
(3, 'Matemática Aplicada', 'Curso de Matemática aplicada à indústria', 3000),
(4, 'Física', 'Curso de Física experimental e teórica', 3200),
(5, 'Química', 'Curso de Química analítica e orgânica', 3000),
(6, 'Administração', 'Curso de Administração de Empresas', 3200),
(7, 'Direito', 'Curso de Direito civil e penal', 3600),
(8, 'Educação Física', 'Curso de licenciatura em Educação Física', 2800),
(9, 'Arquitetura', 'Curso de Arquitetura e Urbanismo', 3600),
(10, 'Biologia', 'Curso de Ciências Biológicas', 3000);

INSERT INTO Avaliacao (id_turma, status_avaliacao, descricao, titulo, tipo_avaliacao, peso, tempo_limite, data_fechamento, data_abertura, nota) VALUES
(1, 'aberta', 'Avaliação parcial 1', 'Prova 1', 'prova', 0.3, 90, '2023-06-15 23:59:59', '2023-06-01 08:00:00', 8.5),
(2, 'fechada', 'Trabalho em grupo', 'Trabalho 1', 'trabalho', 0.2, 0, '2023-06-20 23:59:59', '2023-06-05 08:00:00', 7.0),
(3, 'aberta', 'Avaliação online', 'Quiz 1', 'quiz', 0.1, 30, '2023-06-25 23:59:59', '2023-06-10 08:00:00', 9.0),
(4, 'fechada', 'Prova final', 'Prova Final', 'prova', 0.4, 120, '2023-07-01 23:59:59', '2023-06-20 08:00:00', 6.5),
(5, 'aberta', 'Avaliação prática', 'Prática 1', 'prática', 0.3, 60, '2023-07-05 23:59:59', '2023-06-25 08:00:00', 7.8),
(6, 'fechada', 'Projeto final', 'Projeto', 'projeto', 0.5, 0, '2023-07-10 23:59:59', '2023-06-30 08:00:00', 8.0),
(7, 'aberta', 'Trabalho de pesquisa', 'Pesquisa 1', 'trabalho', 0.3, 0, '2023-07-15 23:59:59', '2023-07-01 08:00:00', 7.2),
(8, 'fechada', 'Seminário', 'Seminário', 'seminário', 0.2, 0, '2023-07-20 23:59:59', '2023-07-05 08:00:00', 9.1),
(9, 'aberta', 'Exercício de laboratório', 'Laboratório', 'prática', 0.2, 120, '2023-07-25 23:59:59', '2023-07-10 08:00:00', 8.5),
(10, 'fechada', 'Avaliação final', 'Avaliação Final', 'prova', 0.4, 90, '2023-07-30 23:59:59', '2023-07-15 08:00:00', 7.7);

INSERT INTO Certificado (codigo_validacao, id_aluno, assinatura_digital, carga_horaria, data_conclusao, nota_final, data_emissao) VALUES
('CERT20230011', 11, 'assinatura1', 3600, '2024-01-15', 8.5, '2024-01-20'),
('CERT20230012', 12, 'assinatura2', 3600, '2024-01-16', 7.0, '2024-01-21'),
('CERT20230013', 13, 'assinatura3', 3000, '2024-01-17', 9.0, '2024-01-22'),
('CERT20230014', 14, 'assinatura4', 3200, '2024-01-18', 6.5, '2024-01-23'),
('CERT20230015', 15, 'assinatura5', 3000, '2024-01-19', 7.8, '2024-01-24'),
('CERT20230016', 16, 'assinatura6', 3200, '2024-01-20', 8.0, '2024-01-25'),
('CERT20230017', 17, 'assinatura7', 3600, '2024-01-21', 7.2, '2024-01-26'),
('CERT20230018', 18, 'assinatura8', 2800, '2024-01-22', 9.1, '2024-01-27'),
('CERT20230019', 19, 'assinatura9', 3600, '2024-01-23', 8.5, '2024-01-28'),
('CERT20230020', 20, 'assinatura10', 3000, '2024-01-24', 7.7, '2024-01-29');

INSERT INTO Material_Educacional (nome, tipo, lote, quantidade, data_entrega, data_validade) VALUES
('Livro de Engenharia de Software', 'Livro', 'L001', 50, '2023-01-10', '2026-01-10'),
('Vídeo Aula Matemática', 'Vídeo', 'L002', 100, '2023-01-15', '2025-01-15'),
('Artigo de Pesquisa Física', 'Artigo', 'L003', 30, '2023-01-20', '2024-01-20'),
('Manual de Química', 'Livro', 'L004', 40, '2023-01-25', '2026-01-25'),
('Slides Administração', 'Slides', 'L005', 60, '2023-01-30', '2025-01-30'),
('Documento Jurídico', 'Documento', 'L006', 20, '2023-02-05', '2024-02-05'),
('Material Esportivo', 'Material', 'L007', 70, '2023-02-10', '2025-02-10'),
('Apostila de Arquitetura', 'Apostila', 'L008', 80, '2023-02-15', '2026-02-15'),
('Revista Biologia', 'Revista', 'L009', 25, '2023-02-20', '2024-02-20'),
('Caderno de Exercícios', 'Caderno', 'L010', 90, '2023-02-25', '2025-02-25');

-- - A procedure é usada porque a operação envolve múltiplos passos
-- (verificações, INSERT, UPDATE) que devem ser executados como uma única
-- transação.
-- - O uso de RAISE EXCEPTION fornece um tratamento de erro e interrompe a
-- execução se as condições (sem vagas, aluno já matriculado) não forem
-- atendidas.
CREATE OR REPLACE PROCEDURE sp_matricular_aluno(p_id_aluno INT, p_id_turma INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_vagas_disp INT;
    v_ja_matriculado INT;
BEGIN
    SELECT count(*)
    INTO v_ja_matriculado
    FROM Aluno_Turma
    WHERE id_aluno = p_id_aluno AND id_turma = p_id_turma;

    IF v_ja_matriculado > 0 THEN
        RAISE EXCEPTION 'Aluno já matriculado nesta turma.';
    END IF;

    SELECT vagas_disp
    INTO v_vagas_disp
    FROM Turma
    WHERE id = p_id_turma;

    IF v_vagas_disp > 0 THEN
        INSERT INTO Aluno_Turma (id_aluno, id_turma, status_inscricao, data_inscricao)
        VALUES (p_id_aluno, p_id_turma, 'ativo', CURRENT_DATE);

        UPDATE Turma
        SET vagas_disp = vagas_disp - 1
        WHERE id = p_id_turma;
        
        RAISE NOTICE 'Matrícula do aluno % na turma % realizada com sucesso.', p_id_aluno, p_id_turma;
    ELSE
        RAISE EXCEPTION 'Não há vagas disponíveis para esta turma.';
    END IF;
END;
$$;

-- Bloco de Código: Procedure para Registrar uma Ocorrência para um Aluno
-- Descrição: Facilita o trabalho do professor ao registrar uma nova
-- ocorrência, inserindo os dados na tabela Ocorrencia e automaticamente
-- associando-a ao aluno correto na tabela Recebe.
-- Justificativa das Decisões:
-- - A ocorrência e sua associação com o aluno são criadas juntas,
-- prevenindo a existência de ocorrências "órfãs" no banco de dados.
CREATE OR REPLACE PROCEDURE sp_registrar_ocorrencia(
    p_id_professor INT,
    p_id_aluno INT,
    p_tipo_ocorrencia VARCHAR(100),
    p_titulo VARCHAR(255),
    p_descricao TEXT
)
LANGUAGE plpgsql AS $$
DECLARE
    v_id_ocorrencia INT;
BEGIN
    INSERT INTO Ocorrencia (id_professor, status_ocorrencia, tipo_ocorrencia, titulo, descricao, data_ocorrencia)
    VALUES (p_id_professor, 'aberta', p_tipo_ocorrencia, p_titulo, p_descricao, CURRENT_DATE)
    RETURNING id INTO v_id_ocorrencia;

    INSERT INTO Recebe (id_aluno, id_ocorrencia)
    VALUES (p_id_aluno, v_id_ocorrencia);
    
    RAISE NOTICE 'Ocorrência % registrada para o aluno %.', v_id_ocorrencia, p_id_aluno;
END;
$$;

-- Bloco de Código: Procedure para Emissão de Certificado
-- Descrição: Automatiza a emissão de certificados. Chama a função
-- fn_verificar_aprovacao e, se o aluno estiver apto, coleta os dados
-- necessários e insere um novo registro na tabela Certificado.
-- Justificativa das Decisões:
-- - Procedure chama a função (fn_verificar_aprovacao) para realizar uma
-- verificação. Essa função está descrita na próxima seção do trabalho.
-- - A validação do certificado combina IDs e o timestamp atual, de forma a
-- garantir alta unicidade.
CREATE OR REPLACE PROCEDURE sp_emitir_certificado(p_id_aluno INT, p_id_turma INT)
LANGUAGE plpgsql AS $$
DECLARE
    v_aprovado BOOLEAN;
    v_dados_turma RECORD;
    v_dados_aluno RECORD;
    v_codigo_unico VARCHAR(255);
BEGIN
    v_aprovado := fn_verificar_aprovacao(p_id_aluno, p_id_turma);

    IF v_aprovado THEN
        SELECT d.carga_horaria INTO v_dados_turma
        FROM Turma t
        JOIN Disciplina d ON t.id_disciplina = d.id
        WHERE t.id = p_id_turma;

        SELECT at.nota_final INTO v_dados_aluno
        FROM Aluno_Turma at
        WHERE at.id_aluno = p_id_aluno AND at.id_turma = p_id_turma;

        v_codigo_unico := 'CERT-' || p_id_turma || '-' || p_id_aluno || '-' || EXTRACT(EPOCH FROM NOW());

        INSERT INTO Certificado (codigo_validacao, id_aluno, carga_horaria, data_conclusao, nota_final, data_emissao)
        VALUES (v_codigo_unico, p_id_aluno, v_dados_turma.carga_horaria, CURRENT_DATE, v_dados_aluno.nota_final, CURRENT_DATE);
        
        RAISE NOTICE 'Certificado emitido para o aluno % na turma %.', p_id_aluno, p_id_turma;
    ELSE
        RAISE NOTICE 'Aluno % não atende aos critérios para certificação na turma %.', p_id_aluno, p_id_turma;
    END IF;
END;
$$;

-- Bloco de Código: Função para Calcular a Média Geral de um Aluno
-- Descrição: Esta função calcula e retorna a média aritmética das notas
-- finais de um aluno, considerando apenas as turmas com status 'concluída' na
-- tabela Aluno_Turma.
-- Justificativa das Decisões:
-- - COALESCE é utilizada para garantir que, caso um aluno não tenha notas,
-- a função retorne 0.00 em vez de NULL, evitando erros em cálculos futuros.
CREATE OR REPLACE FUNCTION fn_calcular_media_aluno(p_id_aluno INT)
RETURNS DECIMAL(4, 2) AS $$
DECLARE
    v_media_final DECIMAL(4, 2);
BEGIN
    SELECT AVG(nota_final)
    INTO v_media_final
    FROM Aluno_Turma
    WHERE id_aluno = p_id_aluno
      AND nota_final IS NOT NULL
      AND status_inscricao = 'concluida';

    RETURN COALESCE(v_media_final, 0.00);
END;
$$ LANGUAGE plpgsql;

-- Bloco de Código: Função para Verificar Aprovação em uma Turma
-- Descrição: Esta função verifica se um aluno atende aos critérios mínimos
-- de nota e frequência para ser considerado aprovado em uma determinada turma.
-- Retorna TRUE para aprovado e FALSE caso contrário.
-- Justificativa das Decisões:
-- - Parâmetros com valores DEFAULT (nota e frequência mínimas), permite que
-- a função seja chamada com critérios diferentes, se necessário.
CREATE OR REPLACE FUNCTION fn_verificar_aprovacao(
    p_id_aluno INT,
    p_id_turma INT,
    p_nota_minima DECIMAL(4, 2) DEFAULT 6.00,
    p_frequencia_minima DECIMAL(5, 2) DEFAULT 75.00
)
RETURNS BOOLEAN AS $$
DECLARE
    v_aprovado BOOLEAN;
BEGIN
    SELECT (nota_final >= p_nota_minima AND frequencia >= p_frequencia_minima)
    INTO v_aprovado
    FROM Aluno_Turma
    WHERE id_aluno = p_id_aluno AND id_turma = p_id_turma;

    RETURN COALESCE(v_aprovado, FALSE);
END;
$$ LANGUAGE plpgsql;

-- Bloco de Código: Função para Obter o Nome Completo de um Usuário
-- Descrição: Uma função de utilidade que recebe o ID de um usuário e
-- retorna seu nome completo, buscando-o na tabela Usuario.
-- Justificativa das Decisões:
-- - Simplifica outras consultas. Em vez de repetir a junção com a tabela
-- Usuario, outras procedures ou relatórios podem chamar esta função.
CREATE OR REPLACE FUNCTION fn_obter_nome_usuario(p_id_usuario INT)
RETURNS VARCHAR(255) AS $$
DECLARE
    v_nome_usuario VARCHAR(255);
BEGIN
    SELECT nome
    INTO v_nome_usuario
    FROM Usuario
    WHERE id = p_id_usuario;
    RETURN v_nome_usuario;
END;
$$ LANGUAGE plpgsql;

-- Bloco de Código: Trigger para Auditar Alterações de Notas
-- Descrição: Cria um registro de auditoria na tabela log_alteracao_notas
-- sempre que o campo nota_final da tabela Aluno_Turma é atualizado.
-- Justificativa das Decisões:
-- - Um trigger é a ferramenta ideal para auditoria, pois é executado
-- automaticamente em resposta a um evento (UPDATE), garantindo que nenhuma
-- alteração passe despercebida.
-- - A cláusula WHEN (OLD.nota_final IS DISTINCT FROM NEW.nota_final)
-- otimiza o processo, fazendo o trigger disparar apenas quando o valor da nota
-- realmente muda.
-- Tabela de Log
CREATE TABLE log_alteracao_notas (
    id SERIAL PRIMARY KEY,
    id_aluno INT,
    id_turma INT,
    nota_antiga DECIMAL(4, 2),
    nota_nova DECIMAL(4, 2),
    usuario_modificador VARCHAR(255) DEFAULT current_user,
    data_alteracao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Função do Trigger
CREATE OR REPLACE FUNCTION fn_trg_log_mudanca_nota()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_alteracao_notas (id_aluno, id_turma, nota_antiga, nota_nova)
    VALUES (OLD.id_aluno, OLD.id_turma, OLD.nota_final, NEW.nota_final);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do Trigger
CREATE OR REPLACE TRIGGER trg_log_nota
AFTER UPDATE ON Aluno_Turma
FOR EACH ROW
WHEN (OLD.nota_final IS DISTINCT FROM NEW.nota_final)
EXECUTE FUNCTION fn_trg_log_mudanca_nota();

-- Bloco de Código: Trigger para Impedir Exclusão de Professor com Turmas
-- Ativas
-- Descrição: Previne a exclusão de um registro da tabela Professor se este
-- professor estiver associado a qualquer turma com status 'ativa'.
-- Justificativa das Decisões:
-- - Trigger BEFORE DELETE mantém a integridade referencial dos dados,
-- permitindo que a validação ocorra antes da exclusão ser confirmada.
-- Função do Trigger
CREATE OR REPLACE FUNCTION fn_trg_checar_professor_ativo()
RETURNS TRIGGER AS $$
DECLARE
    v_turmas_ativas INT;
BEGIN
    SELECT count(*)
    INTO v_turmas_ativas
    FROM Turma
    WHERE id_professor = OLD.id_usuario AND status_turma = 'ativa';

    IF v_turmas_ativas > 0 THEN
        RAISE EXCEPTION 'Não é possível excluir o professor %, pois ele possui % turma(s) ativa(s).', OLD.id_usuario, v_turmas_ativas;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Criação do Trigger
CREATE OR REPLACE TRIGGER trg_impede_exclusao_professor
BEFORE DELETE ON Professor
FOR EACH ROW
EXECUTE FUNCTION fn_trg_checar_professor_ativo();

-- Bloco de Código: Trigger para Atualizar Status dos Alunos ao Fechar uma
-- Turma
-- Descrição: Quando o status_turma de um registro na tabela Turma é
-- alterado para 'encerrada', este trigger atualiza automaticamente o
-- status_inscricao para 'concluida' para todos os alunos matriculados naquela
-- turma.
-- Justificativa das Decisões:
-- - Garante a consistência dos dados entre as tabelas Turma e Aluno_Turma.
-- - Trigger do tipo AFTER UPDATE garante que a ação de cascata só ocorra
-- depois que a atualização na tabela Turma for concluída com sucesso.
-- Função do Trigger
CREATE OR REPLACE FUNCTION fn_trg_atualizar_status_inscricao()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status_turma = 'encerrada' AND OLD.status_turma <> 'encerrada' THEN
        UPDATE Aluno_Turma
        SET status_inscricao = 'concluida'
        WHERE id_turma = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criação do Trigger
CREATE OR REPLACE TRIGGER trg_cascatear_status_turma
AFTER UPDATE ON Turma
FOR EACH ROW
EXECUTE FUNCTION fn_trg_atualizar_status_inscricao();