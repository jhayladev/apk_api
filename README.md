# consumer_api

App Flutter que consume dos APIs: contactos (API propia) y productos (https://dummyjson.com).

## Estructura

```
lib/
├── main.dart
├── config/        urls base y tiempos de espera
├── models/        Contact, Product, ProductsPage, ProductCategory
├── services/      contacts_api.dart, products_api.dart
├── router/        rutas con nombre y paso de argumentos
├── themes/        tema de la app
├── utils/         mensajes (SnackBar)
├── widgets/       componentes reutilizables
└── screens/
    ├── home/      navegación inferior (Contactos / Productos)
    ├── contacts/  lista y formulario de contactos
    ├── products/  lista, detalle y formulario de productos
    └── shared/    pantalla de confirmación de eliminación
```

## Navegación

No se usan `AlertDialog`. Crear, editar y confirmar eliminaciones son pantallas completas abiertas con `Navigator.pushNamed`, que devuelven su resultado con `Navigator.pop`.

## Productos (dummyjson)

Listado paginado con búsqueda, filtro por categoría y orden, detalle por ID, y creación, edición (PATCH) y eliminación simuladas. Dummyjson no guarda los cambios, por eso la app los refleja localmente.
