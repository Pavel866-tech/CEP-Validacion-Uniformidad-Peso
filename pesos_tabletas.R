# Implementación de Control Estadístico de Procesos 
# para la Validación de Uniformidad de Peso de Tabletas

# Cargar librerías
library(qcc)
library(ggplot2)
library(dplyr)

# Establecer semilla, número de subgrupos y tamaño de subgrupo
set.seed(123)

n_subgrupos <- 20
tamaño_subgrupo <- 5

# Datos bajo control (primeros 10 subgrupos)
datos_1 <- matrix(rnorm(10 * tamaño_subgrupo, mean = 500, sd = 2), 
                ncol = tamaño_subgrupo)

# Datos fuera de control (últimos 10 subgrupos → desviación de media)
datos_2 <- matrix(rnorm(10 * tamaño_subgrupo, mean = 510, sd = 6), 
                ncol = tamaño_subgrupo)

# Combinar datos
datos_tableta <- rbind(datos_1, datos_2)

# Convertir a data frame
tableta_dataframe <- as.data.frame(datos_tableta)
colnames(tableta_dataframe) <- paste0("Tableta_", 1:tamaño_subgrupo)

# Añadir ID de subgrupo
tableta_dataframe$Subgrupo <- 1:n_subgrupos

tableta_dataframe

# Gráfica X-barra
xbar_calibrado <- qcc(datos_tableta[1:10, ], type = "xbar", 
                      newdata = datos_tableta[11:20, ], 
                      xlab = "Subgrupo", 
                      ylab = "Peso Promedio (mg)",
                      title = "Control de Medias: Fase I y II")

# Gráfica R
r_chart <- qcc(datos_tableta[1:10,], 
               type = "R",
               newdata = datos_tableta[11:20,],
               xlab = "Subgrupo",
               ylab = "Rango de pesos (mg)",
               title = "Control de Variabilidad (R): Fase I y II")

# Violaciones
fuera_de_limites <- xbar_calibrado$violations$beyond.limits
rachas_invalidas <- xbar_calibrado$violations$violating.runs

length(fuera_de_limites)
length(rachas_invalidas)

datos_afectados <- sort(unique(c(fuera_de_limites, rachas_invalidas)))

tabla_violaciones <- data.frame(
  Subgrupo = datos_afectados,
  Fuera_de_Limites = datos_afectados %in% fuera_de_limites,
  Racha_No_Aleatoria = datos_afectados %in% rachas_invalidas
)

tabla_violaciones

# Gráfica Q-Q clásica
qqnorm(as.vector(datos_1), 
       main = "Gráfico Q-Q de Pesos de Tabletas",
       xlab = "Cuantiles Teóricos",
       ylab = "Cuantiles Observados",
       pch = 16,
       cex = 0.9,
       grid = TRUE)

qqline(as.vector(datos_1), col = "red", lwd = 2)
grid()

# Prueba de Normalidad (Shapiro-Wilk)
shapiro_fase1 <- shapiro.test(as.vector(datos_1))
print(shapiro_fase1)

# Interpretación automática
if(shapiro_fase1$p.value > 0.05) {
  message("Datos Normales: Procede el análisis de capacidad estándar.")
} else {
  warning("Datos No Normales: Considerar transformación Box-Cox o 
          índices no paramétricos.")
}

# Capacidad del proceso (Cp, Cpk y Cpm) para Fase I

# Especificaciones
LIE <- 490
LSE <- 510
peso_objetivo <- 500

process.capability(xbar_calibrado, spec.limits = c(LIE, LSE), 
                   target = peso_objetivo)

# Dividir datos
antes_desvio <- as.vector(datos_1)
despues_desvio  <- as.vector(datos_2)

# Resumen estadístico
mean(antes_desvio)
mean(despues_desvio)

sd(antes_desvio)
sd(despues_desvio)

# Índices de Rendimiento Potencial y Real (Pp y Ppk)

datos_totales <- as.vector(as.matrix(datos_tableta))
media_global <- mean(datos_totales)
sd_largo_plazo <- sd(datos_totales)

Pp <- (LSE - LIE) / (6 * sd_largo_plazo)
Ppk_u <- (LSE - media_global) / (3 * sd_largo_plazo)
Ppk_l <- (media_global - LIE) / (3 * sd_largo_plazo)
Ppk <- min(Ppk_u, Ppk_l)

cat("Media Global:", media_global, "\n")
cat("Desviación Estándar Largo Plazo:", sd_largo_plazo, "\n")
cat("Pp:", Pp, "\n")
cat("Ppk:", Ppk, "\n")

# Comparación de distribuciones (Antes vs. Después)
df_hist <- data.frame(
  Peso = c(antes_desvio, despues_desvio),
  Estado = rep(c("Bajo Control", "Fuera de Control"), each = 50)
)

ggplot(df_hist, aes(x = Peso, fill = Estado)) +
  geom_density(alpha = 0.5) +
  geom_vline(xintercept = c(LIE, LSE), linetype = "dashed", color = "red") +
  labs(title = "Impacto del Desvío en la Distribución de Pesos",
       subtitle = "Líneas rojas indican límites de especificación (LIE/LSE)") +
  theme_minimal()

# Clasificación del Estado del Proceso

# 1. Definir criterios lógicos
es_estable <- length(datos_afectados) == 0

# Un proceso es capaz si el Ppk es mayor o igual a 1.33 (Estándar Industrial)
umbral_capacidad <- 1.33
es_capaz <- Ppk >= umbral_capacidad

# 2. Estructura de Control para Clasificación
if (es_estable && es_capaz) {
  estado_proceso <- "ESTADO A (Ideal)"
  diagnostico <- "Proceso ESTABLE y CAPAZ. Cumple con la calidad requerida y
  es estadísticamente predecible."
} else if (es_estable && !es_capaz) {
  estado_proceso <- "ESTADO B (No Capaz)"
  diagnostico <- "Proceso ESTABLE pero NO CAPAZ. El proceso es predecible, 
  pero su variabilidad es muy alta para las especificaciones."
} else if (!es_estable && es_capaz) {
  estado_proceso <- "ESTADO C (Inestable)"
  diagnostico <- "Proceso CAPAZ pero INESTABLE. Se cumple la especificación por 
  margen amplio, pero existen causas especiales de variación."
} else {
  estado_proceso <- "ESTADO D (Crítico)"
  diagnostico <- "Proceso INESTABLE y NO CAPAZ. El proceso no es predecible y 
  genera producto fuera de especificación (OOS). Requiere detención
  inmediata."
}

# 3. Reporte Final
cat("Estado Identificado:", estado_proceso, "\n")
cat("Diagnóstico: ", diagnostico, "\n")
cat("Métricas Clave:\n")
cat(" - Violaciones Detectadas:", length(datos_afectados), "\n")
cat(" - Índice Ppk:", round(Ppk, 3), "\n")

