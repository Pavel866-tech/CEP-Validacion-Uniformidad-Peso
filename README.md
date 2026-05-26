# Análisis de Uniformidad de Pesos de Tabletas
### Control Estadístico de Procesos (SPC) — Industria Farmacéutica

---

## Descripción General

Este proyecto implementa un sistema de **Control Estadístico de Procesos** (SPC, *Statistical Process Control*) aplicado a la uniformidad de peso de tabletas en la industria farmacéutica, conforme a los lineamientos de la **NOM-059-SSA1-2015**, la **NOM-164-SSA1-2015**, la **ICH Q9(R1)** y la **ICH Q10**.

La uniformidad de peso constituye un atributo crítico de calidad (CQA) cuya variación puede comprometer directamente la eficacia terapéutica y la seguridad del paciente. El análisis implementa un flujo bifásico completo — calibración y monitoreo — que incluye verificación de supuestos estadísticos, análisis de capacidad, detección de desviaciones mediante múltiples métodos de control y clasificación automatizada del estado del proceso.

> **Nota sobre confidencialidad:** Los datos utilizados son simulados con parámetros representativos de un proceso real de compresión de tabletas. En la industria farmacéutica, los datos de proceso constituyen información confidencial protegida por acuerdos de no divulgación (NDA). La simulación garantiza la reproducibilidad íntegra del análisis sin comprometer la confidencialidad de ninguna organización.

---

## Marco Regulatorio

| Normativa | Numeral / Sección | Aplicación en el Proyecto |
|---|---|---|
| NOM-059-SSA1-2015 | Numeral 6.2 | Controles estadísticos en proceso |
| NOM-164-SSA1-2015 | Numeral 9.9.2.3.2 | Verificación Continua del Proceso (CPV) |
| ICH Q9(R1) | Anexo I, Sección A.1.4 | Gráficas de control de Shewhart |
| ICH Q10 | Sección 3.2.1 | Monitoreo del desempeño del proceso |
| FDA Process Validation Guidance | Etapa 3 (CPV) | Índices de desempeño a largo plazo |
| USP \<905\> | — | Uniformidad de unidades de dosificación |

---

## Flujo Analítico

```
Fase I — Calibración                    Fase II — Monitoreo
─────────────────────                   ────────────────────────────
1. Comprobación de normalidad    ──▶    4. Gráficas X-barra/R (I + II)
   · Gráfico Q-Q                        5. Gráficas EWMA y CUSUM
   · Prueba de Shapiro-Wilk             6. Verificación de violaciones
                                           · Tabla de subgrupos afectados
2. Verificación de estabilidad   ──▶    7. Índices Pp y Ppk (largo plazo)
   · Gráfica X-barra                       · Tabla comparativa Cp/Cpk vs Pp/Ppk
   · Gráfica R
                                        8. Comparación de distribuciones
3. Análisis de capacidad         ──▶    9. Clasificación del proceso
   · Cp, Cpk, Cpm                          · Estados A / B / C / D
   · Intervalos de confianza al 95%        · Reporte ejecutivo final
```

---

## Métodos de Control Implementados

| Método | Tipo de Señal Detectada | ARL₁ a 1σ | Marco Regulatorio |
|---|---|---|---|
| X-barra / R (Shewhart) | Desplazamientos ≥ 3σ | ~43.9 | ICH Q9(R1) |
| EWMA (λ = 0.20) | Desplazamientos de 1–2σ | ~10.4 | ICH Q10 |
| CUSUM (k = 0.5, H = 5) | Tendencias acumulativas | ~10.4 | ICH Q10 |

---

## Resultados del Análisis

El proceso simulado corresponde a un escenario de **desgaste progresivo de punzones** en una prensa de tabletas, representado como una tendencia lineal ascendente de 0 a 1.4 mg distribuida en 15 subgrupos de Fase II.

| Índice | Valor | Umbral (≥ 1.50) | Alcance |
|---|---|---|---|
| Cp | 1.848 | ✔ Cumple | Corto plazo — Fase I |
| Cpk | 1.835 | ✔ Cumple | Corto plazo — Fase I |
| Pp | 1.826 | ✔ Cumple | Largo plazo — Global |
| Ppk | 1.743 | ✔ Cumple | Largo plazo — Global |

### Clasificación del Proceso: ESTADO C (Capaz pero Inestable)

> El proceso es técnicamente **CAPAZ** (Ppk = 1.743 ≥ 1.50) pero **INESTABLE**: la evidencia estadística convergente de las gráficas X-barra, EWMA y CUSUM señala la presencia de una causa asignable activa de tipo tendencia gradual que compromete la predictibilidad del proceso. **Acción recomendada:** investigación de causa raíz mediante diagrama de Ishikawa (6M) y emisión de CAPA formal conforme a NOM-059-SSA1-2015.

---

## Estructura del Repositorio

```
spc-tabletas-farma/
├── README.md                  <- Este archivo
├── spc_tabletas.Rmd           <- Documento RMarkdown principal
├── spc_tabletas.R             <- Script R independiente
└── output/
    └── spc_tabletas.html      <- Reporte renderizado
```

---

## Requisitos

### Software

- **R** ≥ 4.1.0
- **RStudio** ≥ 2022.07 (recomendado)

### Paquetes de R

```r
install.packages(c("qcc", "ggplot2", "dplyr", "knitr", "kableExtra"))
```

| Paquete | Uso principal |
|---|---|
| `qcc` | Gráficas de Shewhart, EWMA, CUSUM e índices de capacidad |
| `ggplot2` | Visualización de distribuciones por fase |
| `dplyr` | Manipulación y transformación de datos |
| `knitr` | Renderizado del documento RMarkdown |
| `kableExtra` | Tablas con formato regulatorio |

---

## Reproducibilidad

El análisis es completamente reproducible. La semilla `set.seed(123)` fija los resultados de la simulación estocástica, garantizando que cada ejecución produzca exactamente los mismos datos, gráficas y métricas.

Para renderizar el documento RMarkdown completo:

```r
rmarkdown::render("spc_tabletas.Rmd")
```

Para ejecutar el script independiente:

```r
source("spc_tabletas.R")
```

---

## Conceptos Clave

**Control Estadístico de Procesos (SPC)**
Metodología que distingue entre variación por *causas comunes* (inherente al proceso, aleatoria) y variación por *causas asignables* (atribuible a factores específicos e identificables), permitiendo detectar desviaciones antes de que generen producto fuera de especificación.

**Índices de Capacidad (Cp, Cpk)**
Miden el potencial del proceso bajo condiciones controladas utilizando la variabilidad *within-subgroup* (σ̂ = R̄/d₂). Reflejan el margen entre la variación natural del proceso y los límites de especificación cuando no hay causas asignables presentes.

**Índices de Desempeño (Pp, Ppk)**
Miden el desempeño real del proceso incluyendo todas las fuentes de variación. La diferencia Cpk − Ppk cuantifica el impacto de las causas asignables sobre el desempeño global a largo plazo.

**Verificación Continua del Proceso (CPV)**
Etapa 3 del ciclo de vida del proceso (FDA Process Validation Guidance, 2011): obtención de evidencia estadística durante la producción de rutina que demuestra que el proceso se mantiene bajo control y produce producto conforme de manera consistente.

---

## Referencias

- Gutiérrez Pulido, H., & De la Vara Salazar, R. (2009). *Control estadístico de calidad y Seis Sigma* (2.ª ed.). McGraw-Hill.
- International Council for Harmonisation. (2008). *ICH Q10: Pharmaceutical quality system*. https://www.ich.org
- International Council for Harmonisation. (2023). *ICH Q9(R1): Quality risk management*. https://www.ich.org
- Montgomery, D. C. (2020). *Introduction to statistical quality control* (8.ª ed.). Wiley.
- Scrucca, L. (2004). qcc: An R package for quality control charting and statistical process control. *R News, 4*(1), 11–17.
- Secretaría de Salud. (2015). *NOM-059-SSA1-2015*. Diario Oficial de la Federación.
- Secretaría de Salud. (2015). *NOM-164-SSA1-2015*. Diario Oficial de la Federación.
- U.S. Food and Drug Administration. (2011). *Process validation: General principles and practices*. https://www.fda.gov/media/71021/download

---

## Licencia

Este proyecto se distribuye bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

## Autor

**Pavel Burgueño Camarena**  
