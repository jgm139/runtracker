# Proyecto 1: RunTracker

#### PROGRAMACIÓN OPTIMIZADA PARA DISPOSITIVOS MÓVILES

<br>

---
#### Requerimientos

- Entreno
  - TrainingViewController


- Historial
  - HistoryTableViewController
  - HistoryTableViewCell


- Perfil
  - ProfileViewController


- Opciones
  - OptionsViewController
  - CadenceViewController
  - IntervalViewController
  - HRMViewController


- Clases de apoyo
  - MiBand2
  - MiBand2Service
  - OptionsValues
  - Colours
  - CustomPolyline
  - OptionsConstants

<br>

---
#### Mejoras opcionales:

###### Historial avanzado
> Esta funcionalidad la podemos encontrar desarrollada en las clases:

- DetailViewController
- CustomPolyline

<br>

###### Registro de usuarios
>Nos lo encontramos en las clases:

- LoginViewController
- RegisterViewController
- FirstViewController
- UserSingleton

<br>

###### Almacenamiento
>Todo el almacenamiento de nuestra App se ha realizado utilizando:

- UserDefaults
  - Las opciones


- CoreData (RunTrackerModel)
  - Las historias
  - Los puntos de la ruta
  - Usuarios
  - La sesión

<br>

###### Animación
>Podemos observar la animación del botón de finalizar entrenamiento en el `TrainingViewControles`, en las funciones:

  `startStopAnimation`

  `pauseStopAnimation`

<br>

---
#### Librerías externas:

- [QuickTableViewController](https://github.com/bcylin/QuickTableViewController)
