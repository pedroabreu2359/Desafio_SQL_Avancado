CREATE SCHEMA desafio_avancado;

-- Cenário: uma empresa com vendedores distribuídos em regiões (grupos). 
-- A empresa quer saber:
-- 1) Qual vendedor tem mais vendas registradas;
-- 2) Qual o faturamento total de cada vendedor;
-- 3) Em qual faixa de desempenho cada vendedor se encaixa.

-- Criando tabelas

CREATE TABLE vendedores (
    id INT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    regiao VARCHAR(50) NOT NULL
);
 
CREATE TABLE vendas (
    id INT PRIMARY KEY,
    vendedor_id INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_venda DATE NOT NULL,
    FOREIGN KEY (vendedor_id) REFERENCES vendedores(id)
);

-- Populando as tabelas

INSERT INTO vendedores (id, nome, regiao) VALUES
(1, 'Ana Silva',      'Sudeste'),
(2, 'Bruno Costa',     'Sudeste'),
(3, 'Carla Dias',      'Sudeste'),
(4, 'Diego Souza',     'Sul'),
(5, 'Elaine Rocha',    'Sul'),
(6, 'Felipe Alves',    'Nordeste'),
(7, 'Gabriela Lima',   'Nordeste'),
(8, 'Hugo Martins',    'Nordeste');
 
INSERT INTO vendas (id, vendedor_id, valor, data_venda) VALUES
-- Ana Silva (Sudeste) - alto desempenho
(1,  1, 18000.00, '2026-01-10'),
(2,  1, 15500.00, '2026-02-14'),
(3,  1, 20000.00, '2026-03-05'),
-- Bruno Costa (Sudeste) - médio
(4,  2, 12000.00, '2026-01-20'),
(5,  2,  9500.00, '2026-02-02'),
-- Carla Dias (Sudeste) - baixo, poucas vendas
(6,  3,  3000.00, '2026-03-11'),
-- Diego Souza (Sul) - alto desempenho, muitas vendas
(7,  4, 22000.00, '2026-01-05'),
(8,  4, 19000.00, '2026-01-25'),
(9,  4, 17000.00, '2026-02-08'),
(10, 4, 15000.00, '2026-03-01'),
-- Elaine Rocha (Sul) - baixo
(11, 5, 11000.00, '2026-02-17'),
(12, 5,  8000.00, '2026-03-09'),
-- Felipe Alves (Nordeste) - baixo
(13, 6,  2500.00, '2026-01-30'),
(14, 6,  1800.00, '2026-02-22'),
-- Gabriela Lima (Nordeste) - alto desempenho
(15, 7, 25000.00, '2026-01-12'),
(16, 7, 21000.00, '2026-02-19'),
(17, 7, 19500.00, '2026-03-14');
-- Hugo Martins (Nordeste) - sem nenhuma venda registrada

-- Criando índice para a chave estrangeira:
CREATE INDEX idx_vendas_vendedor_id ON vendas (vendedor_id);

-- Consulta completa
WITH resumo_vendedor AS (
	SELECT
		v.id AS vendedor_id,
        v.nome,
        v.regiao,
        COUNT(vd.id) AS qtd_vendas,
        COALESCE(SUM(vd.valor), 0) AS valor_total
	FROM vendedores v
    LEFT JOIN vendas vd ON vd.vendedor_id = v.id
    GROUP BY v.id, v.nome, v.regiao
)
SELECT
	vendedor_id,
    nome,
    regiao,
    qtd_vendas,
    valor_total,
    ROW_NUMBER() OVER (
		PARTITION BY regiao
        ORDER BY qtd_vendas DESC, valor_total DESC
    ) AS posicao_na_regiao,
    CASE
		WHEN valor_total >= 50000 THEN 'Alto desempenho'
        WHEN valor_total >= 20000 THEN 'Médio desempenho'
        WHEN valor_total > 0 THEN 'Baixo desempenho'
        ELSE 'Sem vendas'
	END AS categoria_desempenho
FROM resumo_vendedor
ORDER BY regiao, posicao_na_regiao;
