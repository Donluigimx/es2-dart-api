import 'lib/es2.dart';
import 'package:args/args.dart';

void main(List<String> arguments) {
  final es2 = ElectribeSampler2();

  ArgParser parser = ArgParser()
    ..addOption('file', mandatory: true);
  ArgResults results = parser.parse(arguments);

  es2.loadAllFile(results['file']);
  es2.readAllFile();
}
