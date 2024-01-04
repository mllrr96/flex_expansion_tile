import 'package:flex_expansion_tile/flex_expansion_tile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flex Expansion Tile Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        dividerColor: Colors.grey,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final tileController = FlexExpansionTileController();
  final formKey = GlobalKey<FormState>();
  final tileKey = GlobalKey();
  String myText =
      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. "
      "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, "
      "when an unknown printer took a galley of type and scrambled it to make a type specimen book. "
      "It has survived not only five centuries, but also the leap into electronic typesetting, "
      "remaining essentially unchanged. It was popularised in the 1960s with the release of "
      "Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing "
      "software like Aldus PageMaker including versions of Lorem Ipsum ";

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 10);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flex Expansion Tile Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 70),
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: const Column(
              children: <Widget>[
                SizedBox(height: 10),
                Text(
                  'Originally based on custom widget called HeaderCard found in flex_color_scheme example app, but has been modified and extended to be more generic and useful.',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          FlexExpansionTile(
            title: const Text('Simple Expansion Tile'),
            child: Column(
              children: List.generate(
                  4, (index) => ListTile(title: Text('List tile $index'))),
            ),
          ),
          space,
          FlexExpansionTile(
            color: Colors.amberAccent,
            title: const Text('Colored Tile with info icon'),
            subtitle: const Text('This tile has a subtitle'),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                Text(myText),
                const SizedBox(height: 10),
              ],
            ),
          ),
          space,
          Form(
            key: formKey,
            child: FlexExpansionTile(
              subtitle: const Text(
                'This is a form inside an expansion tile, when the form is invalid the tile will expand and scroll to the top of the form ',
              ),
              key: tileKey,
              controller: tileController,
              //
              // keep the children in the widget tree when the tile is collapsed.
              // when this is false tileKey.currentContext will be null when the tile is collapsed
              //
              maintainState: true,
              title: const Text('Form Expansion Tile'),
              // Gets called when the tile expand or collapse
              onExpansionChanged: (expanded) async {
                if (expanded) {
                  // waiting for the tile to expand
                  await Future.delayed(const Duration(milliseconds: 200))
                      .then((value) async {
                    // scrolling to the top of the tile
                    await Scrollable.ensureVisible(tileKey.currentContext!,
                        alignment: 0.04,
                        duration: const Duration(milliseconds: 300));
                  });
                }
              },
              child: Column(
                children: <Widget>[
                  space,
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'First Name',
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  space,
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'Last Name',
                    ),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  space,
                ],
              ),
            ),
          ),
          space,
          FlexExpansionTile(
            title: const Text('Initially Expanded Tile'),
            initiallyExpanded: true,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                Text(myText),
                const SizedBox(height: 10),
              ],
            ),
          ),
          space,
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          FocusScope.of(context).unfocus();
          if (!formKey.currentState!.validate()) {
            tileController.expand();
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Form is valid'),
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        tooltip: 'Expand',
        label: const Text('Save'),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
