"""No apps launched: exercise both platform branches with executable fixtures."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1] / 'functions/open.fish'
FISH = shutil.which('fish')


class OpenTests(unittest.TestCase):
    def test_noninteractive_plugin_sourcing_does_not_return_from_fisher(self):
        result = subprocess.run([FISH, '--no-config', '-c',
            'function install_plugin; source "$argv[1]"; echo completed; end; install_plugin "$argv[1]"',
            str(SOURCE.parent.parent / 'conf.d/git.fish')], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'completed')

    def invoke(self, platform, opener, *args):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            scripts = {'uname': f'echo {platform}\n', 'test': 'exit 0\n'}
            if opener:
                scripts[opener] = 'printf "<%s>\\n" "$@" > "$TEST_OUTPUT"\nexit 7\n'
            for name, body in scripts.items():
                file = root / name
                file.write_text('#!/bin/sh\n' + body)
                file.chmod(0o755)
            output = root / 'output'
            result = subprocess.run([FISH, '--no-config', '-c',
                'source "$argv[1]"; open $argv[2..]; set result $status; wait; exit $result',
                str(SOURCE), *args], env=dict(os.environ, PATH=folder, TEST_OUTPUT=str(output)),
                capture_output=True, text=True)
            return result, output.read_text() if output.exists() else ''

    def test_macos_preserves_flags_arguments_and_status(self):
        result, output = self.invoke('Darwin', 'open', '-a', 'Photos', 'a b')
        self.assertEqual(result.returncode, 7)
        self.assertEqual(output, '<-a>\n<Photos>\n<a b>\n')

    def test_linux_uses_xdg(self):
        result, output = self.invoke('Linux', 'xdg-open', 'a b')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(output, '<a b>\n')

    def test_missing_opener_explains_failure(self):
        result, _ = self.invoke('Linux', None, 'a b')
        self.assertEqual(result.returncode, 127)
        self.assertIn('no supported opener', result.stderr)
