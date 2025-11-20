-- 1 Número total de registros
SELECT COUNT(*) AS rl_municiptotal_registros FROM pars;

--  Número total de colunas 
SELECT COUNT(column_name) AS total_colunas
FROM information_schema.columns
WHERE table_name = 'pars';

-- Tipos de dados de cada coluna
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'pars';

-- Média, mínimo, máximo e mediana de idade
SELECT 
    AVG(CAST(pa_idade AS UNSIGNED)) AS media_idade,
    MIN(CAST(pa_idade AS UNSIGNED)) AS idade_min,
    MAX(CAST(pa_idade AS UNSIGNED)) AS idade_max
FROM pars
WHERE 
    -- 1. Garante que o valor é estritamente numérico
    pa_idade REGEXP '^[0-9]+$' 
    -- 2. Filtra por um intervalo de idade plausível
    AND CAST(pa_idade AS UNSIGNED) BETWEEN 1 AND 120;
 
 -- Distribuição do sexo
 
 SELECT 
  pa_sexo,
  COUNT(*) AS total,
  ROUND(100 * COUNT(*) / (SELECT COUNT(*) FROM pars), 2) AS percentual
FROM pars
GROUP BY pa_sexo;

-- Distribuição de complexidade
SELECT pa_nivcpl AS complexidade, COUNT(*) AS total
FROM pars
GROUP BY pa_nivcpl
ORDER BY total DESC;

-- Campos nulos ou vazios

SELECT
  SUM(pa_idade IS NULL OR pa_idade = '') AS idade_vazia,
  SUM(pa_sexo IS NULL OR pa_sexo = '') AS sexo_vazio,
  SUM(pa_cidpri IS NULL OR pa_cidpri = '') AS cid_vazio
FROM pars;

-- Idades fora de faixa
SELECT 
    AVG(CAST(pa_idade AS UNSIGNED)) AS media_idade,
    MIN(CAST(pa_idade AS UNSIGNED)) AS idade_min,
    MAX(CAST(pa_idade AS UNSIGNED)) AS idade_max
FROM pars
WHERE 
    -- 1. Garante que o valor é estritamente numérico
    pa_idade REGEXP '^[0-9]+$' 
    -- 2. Filtra por um intervalo de idade plausível
    AND CAST(pa_idade AS UNSIGNED) BETWEEN 0 AND 120;
  
  -- Sexo diferente de M/F
  
  SELECT * FROM pars
WHERE pa_sexo NOT IN ('M', 'F') OR pa_sexo IS NULL OR pa_sexo = '';

 -- Produção aprovada por tipo de financiamento
 
 SELECT 
  pa_tpfin AS tipo_financiamento, 
  COUNT(*) AS total_procedimentos, 
  SUM(pa_qtdapr) AS quantidade_aprovada
FROM pars
GROUP BY pa_tpfin;

-- Valor médio aprovado por tipo de prestador

SELECT 
  pa_tippre AS tipo_prestador,
  ROUND(AVG(pa_valapr), 2) AS media_valor_aprovado
FROM pars
WHERE pa_valapr IS NOT NULL
GROUP BY pa_tippre;

-- Diferença média entre valor aprovado e produzido
-- valor produzido aprovado" (pa_valapr) foi, em média, 2.14 unidades menor que o "valor produzido" (pa_valpro).
SELECT 
  ROUND(AVG(pa_valapr - pa_valpro), 2) AS media_diferenca_valor
FROM pars
WHERE pa_valapr IS NOT NULL AND pa_valpro IS NOT NULL;

-- 2 CONSULTA PARA IDENTIFICAR VALORES NULOS E INCONSISTÊNCIAS
SELECT 
    COUNT(*) as total_registros,
    SUM(CASE WHEN PA_SEXO IS NULL OR PA_SEXO = '' THEN 1 ELSE 0 END) as sexo_nulo,
    SUM(CASE WHEN PA_IDADE IS NULL OR PA_IDADE = '' THEN 1 ELSE 0 END) as idade_nula,
    SUM(CASE WHEN PA_MUNPCN IS NULL OR PA_MUNPCN = '' THEN 1 ELSE 0 END) as municipio_nulo,
    SUM(CASE WHEN PA_CIDPRI IS NULL OR PA_CIDPRI = '' THEN 1 ELSE 0 END) as cid_principal_nulo,
    SUM(CASE WHEN PA_PROC_ID IS NULL OR PA_PROC_ID = '' THEN 1 ELSE 0 END) as procedimento_nulo,
    SUM(CASE WHEN PA_DOCORIG IS NULL OR PA_DOCORIG = '' THEN 1 ELSE 0 END) as documento_origem_nulo
FROM PARS;


-- 3.1 Volume e Perfil dos Procedimentos OK
# Quantos procedimentos ambulatoriais foram realizados em Santa Rosa no último mês, trimestre e 
# ano (crie a tabela de granularidade temporal a partir do arquivo 04-gera-dimtempo-mysql.sql).

SELECT 
    ts.ip_dscr AS procedimento,
    COUNT(*) AS total_procedimentos,
    p.PA_MVM data_movimento
FROM pars p
JOIN tb_sigtaw ts 
    ON p.PA_PROC_ID = ts.ip_cod 
LEFT JOIN tb_municip mun
    ON mun.co_municip = p.PA_MUNPCN
WHERE mun.ds_nome = 'Santa Rosa'
  AND p.PA_MVM LIKE '2025%'
GROUP BY ts.ip_dscr, data_movimento;

   


# Distribuição por especialidade/procedimento (consultas básicas, exames de imagem, oncologia, psiquiatria, etc).
# Evolução temporal: picos e quedas na demanda.


-- Último mês (por exemplo, 202511)
SELECT 
    'Último mês' AS periodo,
    COUNT(*) AS total_procedimentos
FROM pars p
LEFT JOIN tb_municip mun ON mun.co_municip = p.PA_MUNPCN
WHERE mun.ds_nome = 'Santa Rosa'
  AND p.PA_MVM = (SELECT MAX(anomes) FROM dimtempo);

-- Último trimestre
SELECT 
    'Último trimestre' AS periodo,
    COUNT(*) AS total_procedimentos
FROM pars p
LEFT JOIN tb_municip mun ON mun.co_municip = p.PA_MUNPCN
JOIN dimtempo d ON d.anomes = p.PA_MVM
WHERE mun.ds_nome = 'Santa Rosa'
  AND d.trimestre = (SELECT MAX(trimestre) FROM dimtempo WHERE ano = 2025)
  AND d.ano = 2025;

-- Ano inteiro de 2025
SELECT 
    'Ano de 2025' AS periodo,
    COUNT(*) AS total_procedimentos
FROM pars p
LEFT JOIN tb_municip mun ON mun.co_municip = p.PA_MUNPCN
WHERE mun.ds_nome = 'Santa Rosa'
  AND p.PA_MVM LIKE '2025%';


-- Distribuição por especialidade / procedimento
SELECT 
    ts.ip_dscr AS procedimento,
    COUNT(*) AS total_procedimentos
FROM pars p
JOIN tb_sigtaw ts 
    ON p.PA_PROC_ID = ts.ip_cod
LEFT JOIN tb_municip mun
    ON mun.co_municip = p.PA_MUNPCN
WHERE mun.ds_nome = 'Santa Rosa'
  AND p.PA_MVM LIKE '2025%'
GROUP BY ts.ip_dscr
ORDER BY total_procedimentos DESC;

-- Evolução temporal (tendência e picos)
SELECT 
    dt.mesext AS mes,
    SUM(COUNT(*)) OVER (ORDER BY dt.anomes) AS acumulado,
    COUNT(*) AS total_mes
FROM pars p
JOIN tb_sigtaw ts 
    ON p.PA_PROC_ID = ts.ip_cod
LEFT JOIN tb_municip mun
    ON mun.co_municip = p.PA_MUNPCN
JOIN dimtempo dt
    ON dt.anomes = p.PA_MVM
WHERE mun.ds_nome = 'Santa Rosa'
  AND dt.ano = 2025
GROUP BY dt.mesext, dt.anomes
ORDER BY dt.anomes;

-- 3.2 Ranking de produção por estabelecimento OK
-- Ranking por volume total de procedimentos aprovados

SELECT 
    pa_coduni AS cnes_estabelecimento,
    SUM(pa_qtdapr) AS total_aprovados,
    SUM(pa_qtdpro) AS total_produzidos,
    ROUND(100 * SUM(pa_qtdapr) / NULLIF(SUM(pa_qtdpro), 0), 2) AS taxa_aprovacao
FROM pars
GROUP BY pa_coduni
ORDER BY total_aprovados DESC
LIMIT 10;

-- Comparativo Produzido x Aprovado (todos os estabelecimentos)
SELECT 
    PA_CODUNI AS cnes_estabelecimento,
    SUM(PA_QTDPRO) AS qtd_produzida,
    SUM(PA_QTDAPR) AS qtd_aprovada,
    (SUM(PA_QTDAPR) - SUM(PA_QTDPRO)) AS diferenca,
    ROUND(100 * SUM(PA_QTDAPR) / NULLIF(SUM(PA_QTDPRO), 0), 2) AS taxa_aprovacao_percentual
FROM pars
GROUP BY PA_CODUNI
ORDER BY taxa_aprovacao_percentual DESC;

-- Evolução mensal da produção por estabelecimento
SELECT 
    PA_CODUNI AS cnes_estabelecimento,
    PA_CMP AS competencia,
    SUM(PA_QTDPRO) AS total_produzido,
    SUM(PA_QTDAPR) AS total_aprovado,
    ROUND(100 * SUM(PA_QTDAPR) / NULLIF(SUM(PA_QTDPRO), 0), 2) AS taxa_aprovacao
FROM pars
GROUP BY PA_CODUNI, PA_CMP
ORDER BY PA_CODUNI, PA_CMP;

-- Taxa média de aprovação por tipo de unidade (PA_TPUPS)

SELECT 
    PA_TPUPS AS tipo_unidade,
    COUNT(DISTINCT PA_CODUNI) AS qtd_estabelecimentos,
    SUM(PA_QTDPRO) AS total_produzido,
    SUM(PA_QTDAPR) AS total_aprovado,
    ROUND(100 * SUM(PA_QTDAPR) / NULLIF(SUM(PA_QTDPRO), 0), 2) AS taxa_media_aprovacao
FROM pars
GROUP BY PA_TPUPS
ORDER BY taxa_media_aprovacao DESC;

-- Valor financeiro aprovado por estabelecimento
SELECT 
    PA_CODUNI AS cnes_estabelecimento,
    SUM(PA_VALPRO) AS valor_produzido,
    SUM(PA_VALAPR) AS valor_aprovado,
    ROUND(100 * SUM(PA_VALAPR) / NULLIF(SUM(PA_VALPRO), 0), 2) AS taxa_valor_aprovacao
FROM pars
GROUP BY PA_CODUNI
ORDER BY valor_aprovado DESC;

#3.3 OK
# Perfil Demográfico e Epidemiológico da População Atendida

   # Distribuição por sexo e faixa etária.
	
	SELECT 
    CASE 
        WHEN PA_SEXO = 'M' THEN 'Masculino'
        WHEN PA_SEXO = 'F' THEN 'Feminino'
        ELSE 'Não informado'
    END AS Sexo,
    CASE 
        WHEN CAST(PA_IDADE AS UNSIGNED) BETWEEN 0 AND 9 THEN '0 a 9'
        WHEN CAST(PA_IDADE AS UNSIGNED) BETWEEN 10 AND 19 THEN '10 a 19'
        WHEN CAST(PA_IDADE AS UNSIGNED) BETWEEN 20 AND 29 THEN '20 a 29'
        WHEN CAST(PA_IDADE AS UNSIGNED) BETWEEN 30 AND 39 THEN '30 a 39'
        WHEN CAST(PA_IDADE AS UNSIGNED) BETWEEN 40 AND 49 THEN '40 a 49'
        WHEN CAST(PA_IDADE AS UNSIGNED) BETWEEN 50 AND 59 THEN '50 a 59'
        WHEN CAST(PA_IDADE AS UNSIGNED) BETWEEN 60 AND 69 THEN '60 a 69'
        WHEN CAST(PA_IDADE AS UNSIGNED) >= 70 THEN '70+'
        ELSE 'Idade inválida ou nula'
    END AS Faixa_Etaria,
    COUNT(*) AS Total,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM pars WHERE PA_SEXO IS NOT NULL),
        2
    ) AS Percentual
FROM pars
WHERE PA_IDADE IS NOT NULL
GROUP BY Sexo, Faixa_Etaria
ORDER BY Sexo, MIN(CAST(PA_IDADE AS UNSIGNED));


   # Principais diagnósticos (CID) atendidos (hipertensão, diabetes, câncer, etc).

SELECT 
    p.PA_CIDPRI AS cid,
    COUNT(*) AS total_atendimentos
FROM pars p
JOIN tb_municip mun ON mun.co_municip = p.PA_MUNPCN
WHERE mun.ds_nome = 'Santa Rosa'
  AND p.PA_MVM LIKE '2025%'
  AND p.PA_CIDPRI IS NOT NULL
GROUP BY p.PA_CIDPRI
ORDER BY total_atendimentos DESC;


   # Procedimentos recorrentes para doenças crônicas.

SELECT 
    ts.ip_dscr AS procedimento,
    p.PA_CIDPRI AS cid_principal,
    COUNT(*) AS total_registros
FROM pars p
JOIN tb_sigtaw ts 
    ON ts.ip_cod = p.PA_PROC_ID
JOIN tb_municip mun
    ON mun.co_municip = p.PA_MUNPCN
WHERE mun.ds_nome = 'Santa Rosa'
  AND p.PA_MVM LIKE '2025%'
  AND (
        p.PA_CIDPRI LIKE 'E1%'   -- diabetes
     OR p.PA_CIDPRI LIKE 'I1%'   -- hipertensão
     OR p.PA_CIDPRI LIKE 'C%'    -- oncologia
     OR p.PA_CIDPRI LIKE 'J%'    -- respiratório
     OR p.PA_CIDPRI LIKE 'F%'    -- psiquiatria
  )
GROUP BY ts.ip_dscr, p.PA_CIDPRI
ORDER BY total_registros DESC;


# 3.4. Fluxos Regionais e Acesso

  #  Municípios de origem dos pacientes atendidos em Santa Rosa.
	# co_municip santa rosa = 431720
select mun.ds_nome  from pars p
left join tb_municip mun
on p.PA_MUNPCN = mun.co_municip
where p.PA_UFMUN = 431720

#  Quantos atendimentos feitos em Ijuí são de moradores de outros municípios
select count(*) from pars p
where p.PA_UFMUN = 431020 and p.PA_MNDIF = 1

  #  Identificação de regiões dependentes do
# Hospital Vida & Saúde ou UBS locais.

?

-- 3.5 Total de valores aprovados x produzidos — Santa Rosa

SELECT 
    CASE
        WHEN PA_UFMUN LIKE '%431720%' THEN 'Santa Rosa'
        ELSE 'Outros Municípios'
    END AS municipio,
    SUM(PA_VALPRO) AS valor_produzido,
    SUM(PA_VALAPR) AS valor_aprovado,
    ROUND(SUM(PA_VALAPR) - SUM(PA_VALPRO), 2) AS diferenca,
    ROUND(100 * SUM(PA_VALAPR) / NULLIF(SUM(PA_VALPRO), 0), 2) AS taxa_aprovacao
FROM pars
GROUP BY municipio;

-- Ranking de estabelecimentos de Santa Rosa por valor aprovado Secretaria estadual de saude
SELECT 
    PA_CODUNI AS cnes_estabelecimento,
    SUM(PA_VALPRO) AS valor_produzido,
    SUM(PA_VALAPR) AS valor_aprovado,
    ROUND(SUM(PA_VALAPR) - SUM(PA_VALPRO), 2) AS diferenca_valor,
    ROUND(100 * SUM(PA_VALAPR) / NULLIF(SUM(PA_VALPRO), 0), 2) AS taxa_aprovacao
FROM pars
WHERE PA_UFMUN LIKE '%431720%'
GROUP BY PA_CODUNI
ORDER BY valor_aprovado DESC;

-- 3.6-- Oncologia — Quimioterapia e Radioterapia
SELECT 
    'Oncologia' AS area,
    SUM(PA_QTDPRO) AS total_produzido,
    SUM(PA_QTDAPR) AS total_aprovado,
    ROUND(100 * SUM(PA_QTDAPR) / NULLIF(SUM(PA_QTDPRO), 0), 2) AS taxa_aprovacao,
    SUM(PA_VALAPR) AS valor_total_aprovado
FROM pars
WHERE PA_PROC_ID LIKE '0304%'   -- Quimioterapia
   OR PA_PROC_ID LIKE '0305%'   -- Radioterapia
   OR PA_PROC_ID LIKE '0306%'   -- Outras terapias oncológicas
GROUP BY area;

-- Saúde Mental — Psiquiatria e Psicologia
SELECT 
    'Saúde Mental' AS area,
    SUM(PA_QTDPRO) AS total_produzido,
    SUM(PA_QTDAPR) AS total_aprovado,
    ROUND(100 * SUM(PA_QTDAPR) / NULLIF(SUM(PA_QTDPRO), 0), 2) AS taxa_aprovacao,
    SUM(PA_VALAPR) AS valor_total_aprovado
FROM pars
WHERE PA_PROC_ID LIKE '0701%'   -- Atendimento psiquiátrico
   OR PA_PROC_ID LIKE '0702%'   -- Atendimento psicológico
   OR PA_PROC_ID LIKE '0703%'   -- CAPS / Saúde Mental
GROUP BY area;

-- Atenção Básica — Consultas e acompanhamento de doenças crônicas
SELECT 
    'Atenção Básica' AS area,
    SUM(PA_QTDPRO) AS total_produzido,
    SUM(PA_QTDAPR) AS total_aprovado,
    ROUND(100 * SUM(PA_QTDAPR) / NULLIF(SUM(PA_QTDPRO), 0), 2) AS taxa_aprovacao,
    SUM(PA_VALAPR) AS valor_total_aprovado
FROM pars
WHERE PA_PROC_ID LIKE '0201%'   -- Consultas médicas
   OR PA_PROC_ID LIKE '0202%'   -- Consultas de enfermagem
   OR PA_PROC_ID LIKE '0203%'   -- Acompanhamento doenças crônicas
GROUP BY area;

-- volução mensal (por área)
SELECT 
    CASE 
        WHEN PA_PROC_ID LIKE '0304%' OR PA_PROC_ID LIKE '0305%' THEN 'Oncologia'
        WHEN PA_PROC_ID LIKE '070%' THEN 'Saúde Mental'
        WHEN PA_PROC_ID LIKE '020%' THEN 'Atenção Básica'
        ELSE 'Outros'
    END AS area,
    PA_CMP AS competencia,
    SUM(PA_VALAPR) AS valor_aprovado,
    SUM(PA_QTDAPR) AS qtd_aprovada,
    ROUND(SUM(PA_VALAPR) / NULLIF(SUM(PA_QTDAPR), 0), 2) AS gasto_medio
FROM pars
WHERE PA_UFMUN LIKE '%431720%'
GROUP BY area, PA_CMP
ORDER BY PA_CMP, area;

-- 3.7 Comparar media regional OK
WITH base AS (
    SELECT 
        mun.ds_nome AS municipio,
        dt.anomes,
        COUNT(*) AS total_procedimentos
    FROM pars p
    JOIN tb_sigtaw ts ON p.PA_PROC_ID = ts.ip_cod
    JOIN tb_municip mun ON mun.co_municip = p.PA_MUNPCN
    JOIN dimtempo dt ON dt.anomes = p.PA_MVM
    WHERE mun.ds_nome IN ('Santa Rosa', 'Ijuí', 'Santo Ângelo')
      AND dt.ano = 2025
    GROUP BY mun.ds_nome, dt.anomes
)
SELECT 
    b1.municipio,
    b1.anomes,
    b1.total_procedimentos,
    ROUND(AVG(b2.total_procedimentos), 0) AS media_regional,
    b1.total_procedimentos - ROUND(AVG(b2.total_procedimentos), 0) AS dif_media
FROM base b1
JOIN base b2 ON b1.anomes = b2.anomes
GROUP BY b1.municipio, b1.anomes
ORDER BY b1.anomes, b1.municipio;


# Identificar tendências de aumento (por exemplo, envelhecimento –> mais procedimentos cardiológicos e oncológicos).

SELECT 
    ts.ip_dscr AS procedimento,
    CASE
        WHEN ts.ip_dscr LIKE '%cardio%' THEN 'Cardiologia'
        WHEN ts.ip_dscr LIKE '%onco%' THEN 'Oncologia'
        WHEN ts.ip_dscr LIKE '%imagem%' OR ts.ip_dscr LIKE '%raio%' THEN 'Imagem'
        WHEN ts.ip_dscr LIKE '%psiq%' THEN 'Psiquiatria'
        ELSE 'Outros'
    END AS especialidade,
    dt.anomes,
    COUNT(*) AS total
FROM pars p
JOIN tb_sigtaw ts ON p.PA_PROC_ID = ts.ip_cod
JOIN tb_municip mun ON mun.co_municip = p.PA_MUNPCN
JOIN dimtempo dt ON dt.anomes = p.PA_MVM
WHERE mun.ds_nome = 'Santa Rosa'
  AND dt.ano = 2025
GROUP BY 
    ts.ip_dscr,
    especialidade,
    dt.anomes
ORDER BY 
    especialidade, dt.anomes;




SELECT PA_SEXO, PA_IDADE, COUNT(*)
FROM pars
WHERE PA_SEXO = 'OMISSO' OR PA_IDADE >= 150
GROUP BY PA_SEXO, PA_IDADE;


select count(*) from pars where PA_SEXO


update pars set PA_SEXO = "OMISSO"
where PA_SEXO not in ("M", "F");



