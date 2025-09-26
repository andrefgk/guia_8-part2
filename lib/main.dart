import 'package:flutter/material.dart'; // Importa el paquete de UI de Flutter
import 'package:flutter_sqlite/database_helper.dart'; // Importa el helper para la base de datos SQLite
import 'libros.dart'; // Importa el modelo de datos Libro

void main() { // Función principal
  runApp(const MyApp()); // Inicia la aplicación
}

class MyApp extends StatelessWidget { // Widget principal sin estado
  const MyApp ({super.key}); // Constructor con clave

  @override
  Widget build (BuildContext context) { // Método build para construir la interfaz
    return MaterialApp( // Retorna la aplicación
      title: 'Flutter Demo', // Título de la app
      theme: ThemeData( // Define el tema
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // Paleta de colores
        useMaterial3: true, // Usa Material Design 3
      ),
      home: const MyHomePage(), // Página principal
    );
  }
}

class MyHomePage extends StatefulWidget { // Widget con estado
  const MyHomePage({super.key}); // Constructor

  @override 
  State<MyHomePage> createState() => _MyHomePageState (); // Crea el estado
}

class _MyHomePageState extends State<MyHomePage> { // Clase del estado
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instancia del helper de BD
  final TextEditingController _EditTituloLibro = TextEditingController(); // Controlador de texto para el campo de título
  List<Libro> _items = []; // Lista de libros que se mostrará en pantalla

  @override 
  void initState() { // Inicializa el estado
    super.initState(); // Llama al initState padre
    _cargarListaLibros(); // Carga los libros desde la base de datos
  }

  Future<void> _cargarListaLibros() async { // Método para cargar libros
    final items = await _dbHelper.getItems(); // Obtiene los libros de la BD
    setState(() { // Actualiza el estado
      _items = items; // Asigna los libros a la lista local
    });
  }

  void _agregarNuevoLibro(String tituloLibro) async { // Método para agregar un nuevo libro
    final nuevoLibro = Libro(tituloLibro: tituloLibro); // Crea una instancia del modelo Libro
    await _dbHelper.insertLibro(nuevoLibro); // Inserta el libro en la BD
    print("SE AGREGO EL NUEVO LIBRO"); // Mensaje de consola
    
    _cargarListaLibros(); // Recarga la lista para mostrar el nuevo libro
  }

  void _mostrarVentanaAgregar() { // Muestra el diálogo para agregar un nuevo libro
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Titulo"), // Título del diálogo
          content: TextField( // Campo de texto para ingresar el título
            controller: _EditTituloLibro, // Controlador del campo
            decoration: const InputDecoration(hintText: "Ingrese el titulo"), // Placeholder
          ),
          actions: [ // Botones del diálogo
            TextButton(
              onPressed: () {
                if (_EditTituloLibro.text.isNotEmpty) { // Verifica que el campo no esté vacío
                  _agregarNuevoLibro(_EditTituloLibro.text.toString()); // Agrega el libro
                  _EditTituloLibro.clear(); // Limpia el campo
                  Navigator.of(context).pop(); // Cierra el diálogo
                }
              },
              child: Text("Agregar") // Texto del botón
            )
          ],
        );
      }
    );
  }

  void _eliminarLibro(int id) async { // Elimina un libro por ID
    await _dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]); // Ejecuta eliminación en la BD
    _cargarListaLibros(); // Recarga la lista para reflejar el cambio
  }

  void _mostrarMensajeModificar(int id) { // Muestra confirmación de eliminación
    showDialog( // Muestra diálogo
      context: context, // Contexto actual
      builder: (context) {
        return AlertDialog(
          title: Text("Confirmar eliminacion"), // Título del diálogo
          content: Text("Estas seguro de que quieres eliminar este libro?"), // Mensaje de confirmación
          actions: [ // Botones del diálogo
            TextButton( // Botón cancelar
              onPressed: () {
                _eliminarLibro(id); // Elimina el libro
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text("Cancelar"), // Texto del botón
            ),
            TextButton( // Botón eliminar
              onPressed: () {
                _eliminarLibro(id); // Elimina el libro
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text("Eliminar"), // Texto del botón
            ),
          ],
        );
      },
    );
  }

  void _actualizarLibro(int id, String nuevoTitulo) async { // Actualiza el título del libro
    await _dbHelper.actualizar( // Ejecuta actualización en la BD
      'libros', // Tabla
      {'tituloLibro': nuevoTitulo}, // Nuevo valor
      where: 'id = ?', // Condición
      whereArgs: [id], // Argumento
    );
    _cargarListaLibros(); // Recarga la lista para reflejar el cambio
  }

  void _ventanaEditar(int id, String tituloActual) { // Muestra diálogo para editar el título
    TextEditingController tituloController = TextEditingController(text: tituloActual); // Controlador con texto inicial
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modificar Titulo del Libro"), // Título del diálogo
          content: TextField(
            controller: tituloController, // Controlador del campo
            decoration: InputDecoration(
              hintText: "Escribe el nuevo titulo", // Placeholder
            ),
          ),
          actions: [
            TextButton( // Botón cancelar
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text("Cancelar"), // Texto del botón
            ),
            TextButton( // Botón guardar
              onPressed: () {
                if (tituloController.text.isNotEmpty) { // Verifica si hay texto
                  _actualizarLibro(id, tituloController.text.toString()); // Actualiza libro
                }
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text("Guardar"), // Texto del botón
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) { // Construye la interfaz principal
    return Scaffold( // Estructura visual de la pantalla
      appBar: AppBar( // Barra superior
        title: Text("SqlLite Flutter"), // Título de la app
        backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Color de fondo
      ),
      body: ListView.separated( // Lista con separadores entre ítems
        itemCount: _items.length, // Cantidad de elementos
        separatorBuilder: (context, index) => Divider(), // Separador entre ítems
        itemBuilder: (context, index) { // Constructor de cada ítem
          final libro = _items[index]; // Obtiene el libro actual
          return ListTile( // Elemento de lista
            title: Text(libro.tituloLibro), // Muestra el título del libro
            subtitle: Text('ID: ${libro.id}'), // Muestra el ID del libro
            trailing: IconButton( // Botón de eliminar
              icon: Icon(Icons.delete, color: Colors.grey), // Ícono de basura
              onPressed: () {
                _mostrarMensajeModificar(int.parse(libro.id.toString())); // Muestra confirmación de eliminación
              },
            ),
            onTap: () { // Acción al tocar el ítem
              _ventanaEditar(int.parse(libro.id.toString()), libro.tituloLibro); // Muestra diálogo de edición
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton( // Botón flotante para agregar
        onPressed: _mostrarVentanaAgregar, // Acción al presionar
        child: Icon(Icons.add), // Ícono de agregar
      ),
    );
  }
}