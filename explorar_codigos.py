import pandas as pd
import mysql.connector

connection = mysql.connector.connect(
    host='192.168.196.63',
    user='root',
    password='ABC!abc123',
    database='projeto1'
)

cursor = connection.cursor(dictionary=True)

# =============================================================================
# Explorar todos os procedimentos distintos com seus códigos e descrições
# =============================================================================

print("="*150)
print("TODOS OS PROCEDIMENTOS COM CÓDIGOS - ORDENADOS POR PA_PROC_ID")
print("="*150)

query_all_procs = """
SELECT DISTINCT
    p.PA_PROC_ID AS codigo,
    s.ip_dscr AS descricao,
    COUNT(*) AS frequencia
FROM pars p
LEFT JOIN tb_sigtaw s ON s.ip_cod = p.PA_PROC_ID
WHERE p.PA_UFMUN = '431720'
GROUP BY p.PA_PROC_ID, s.ip_dscr
ORDER BY p.PA_PROC_ID
"""

cursor.execute(query_all_procs)
df_all = pd.DataFrame(cursor.fetchall())

print(df_all.to_string(index=False))
print(f"\nTotal de procedimentos distintos: {len(df_all)}")

# =============================================================================
# Buscar por palavras-chave para Oncologia
# =============================================================================
print("\n" + "="*150)
print("BUSCA: Procedimentos contendo 'ONCOLOG', 'QUIMIO', 'RADIO', 'TUMOR', 'CANCER'")
print("="*150)

query_oncologia = """
SELECT 
    p.PA_PROC_ID AS codigo,
    s.ip_dscr AS descricao,
    COUNT(*) AS frequencia
FROM pars p
LEFT JOIN tb_sigtaw s ON s.ip_cod = p.PA_PROC_ID
WHERE p.PA_UFMUN = '431720'
  AND (s.ip_dscr LIKE '%ONCOLOG%' 
       OR s.ip_dscr LIKE '%QUIMIO%' 
       OR s.ip_dscr LIKE '%RADIO%'
       OR s.ip_dscr LIKE '%TUMOR%'
       OR s.ip_dscr LIKE '%CANCER%')
GROUP BY p.PA_PROC_ID, s.ip_dscr
ORDER BY frequencia DESC
"""

cursor.execute(query_oncologia)
df_oncologia = pd.DataFrame(cursor.fetchall())
if len(df_oncologia) > 0:
    print(df_oncologia.to_string(index=False))
else:
    print("Nenhum procedimento encontrado com essas palavras-chave")

# =============================================================================
# Buscar por palavras-chave para Saúde Mental
# =============================================================================
print("\n" + "="*150)
print("BUSCA: Procedimentos contendo 'PSIC', 'MENTAL', 'PSIQUIAT', 'CONSUL', 'TERAPIA'")
print("="*150)

query_saude_mental = """
SELECT 
    p.PA_PROC_ID AS codigo,
    s.ip_dscr AS descricao,
    COUNT(*) AS frequencia
FROM pars p
LEFT JOIN tb_sigtaw s ON s.ip_cod = p.PA_PROC_ID
WHERE p.PA_UFMUN = '431720'
  AND (s.ip_dscr LIKE '%PSIC%' 
       OR s.ip_dscr LIKE '%MENTAL%' 
       OR s.ip_dscr LIKE '%PSIQUIAT%'
       OR s.ip_dscr LIKE '%TERAPIA%')
GROUP BY p.PA_PROC_ID, s.ip_dscr
ORDER BY frequencia DESC
"""

cursor.execute(query_saude_mental)
df_saude_mental = pd.DataFrame(cursor.fetchall())
if len(df_saude_mental) > 0:
    print(df_saude_mental.to_string(index=False))
else:
    print("Nenhum procedimento encontrado com essas palavras-chave")

# =============================================================================
# Buscar por palavras-chave para Atenção Básica Clínica
# =============================================================================
print("\n" + "="*150)
print("BUSCA: Procedimentos contendo 'CONSUL', 'AVALIA', 'ATEND', 'PROC' (sem 'INSPEC', 'LICENC', 'PROJETO')")
print("="*150)

query_atencao_basica = """
SELECT 
    p.PA_PROC_ID AS codigo,
    s.ip_dscr AS descricao,
    COUNT(*) AS frequencia
FROM pars p
LEFT JOIN tb_sigtaw s ON s.ip_cod = p.PA_PROC_ID
WHERE p.PA_UFMUN = '431720'
  AND (s.ip_dscr LIKE '%CONSUL%' 
       OR s.ip_dscr LIKE '%AVALIA%' 
       OR s.ip_dscr LIKE '%ATEND%')
  AND s.ip_dscr NOT LIKE '%INSPEC%'
  AND s.ip_dscr NOT LIKE '%LICENC%'
  AND s.ip_dscr NOT LIKE '%PROJETO%'
GROUP BY p.PA_PROC_ID, s.ip_dscr
ORDER BY frequencia DESC
"""

cursor.execute(query_atencao_basica)
df_atencao_basica = pd.DataFrame(cursor.fetchall())
if len(df_atencao_basica) > 0:
    print(df_atencao_basica.to_string(index=False))
else:
    print("Nenhum procedimento encontrado com essas palavras-chave")

# =============================================================================
# Resumo geral de códigos por range
# =============================================================================
print("\n" + "="*150)
print("RESUMO: Quantidade de procedimentos por range de código")
print("="*150)

query_ranges = """
SELECT 
    CASE 
        WHEN p.PA_PROC_ID LIKE '01%' THEN '01xx - Atenção Básica'
        WHEN p.PA_PROC_ID LIKE '02%' THEN '02xx - Outros'
        WHEN p.PA_PROC_ID LIKE '03%' THEN '03xx - Possível Oncologia'
        WHEN p.PA_PROC_ID LIKE '04%' THEN '04xx - Possível Oncologia'
        WHEN p.PA_PROC_ID LIKE '05%' THEN '05xx - Outros'
        WHEN p.PA_PROC_ID LIKE '06%' THEN '06xx - Outros'
        WHEN p.PA_PROC_ID LIKE '07%' THEN '07xx - Possível Saúde Mental'
        WHEN p.PA_PROC_ID LIKE '08%' THEN '08xx - Outros'
        WHEN p.PA_PROC_ID LIKE '09%' THEN '09xx - Outros'
        ELSE 'Outro'
    END AS range_codigo,
    COUNT(DISTINCT p.PA_PROC_ID) AS qtd_codigos_distintos,
    COUNT(*) AS qtd_total_registros
FROM pars p
WHERE p.PA_UFMUN = '431720'
GROUP BY range_codigo
ORDER BY qtd_total_registros DESC
"""

cursor.execute(query_ranges)
df_ranges = pd.DataFrame(cursor.fetchall())
print(df_ranges.to_string(index=False))

cursor.close()
connection.close()
