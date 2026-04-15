Implementación de SPC para la Validación de Uniformidad de Peso

Descripción:
Este proyecto automatiza el Control Estadístico de Procesos (SPC) para el pesado de tabletas, 
enfocado en el cumplimiento de la NOM-059 y criterios de integridad de datos.

Características Principales:
•Validación de Normalidad: Uso de Shapiro-Wilk y Gráficos Q-Q.
•Fase I y II: Diferenciación entre límites de control y monitoreo de nuevos datos.
•Detección de Violaciones: Identificación automática de puntos fuera de límites y rachas.
•Clasificación de Estados (A-D): Diagnóstico ejecutivo basado en gráficos de control de Shewhart e índices de potencialidad.

Requisitos:
Se requiere R y las librerías: `qcc`, `ggplot2`, `dplyr`.
