# -*- encoding: utf-8 -*-
"""
Test for keria.__init__
"""

import logging
import unittest
from unittest.mock import Mock
import keria


class TestKeriaInit(unittest.TestCase):
    def test_set_log_level_with_debug(self):
        mock_logger = Mock()
        keria.set_log_level("DEBUG", mock_logger)
        self.assertEqual(keria.ogler.level, logging.DEBUG)
        mock_logger.setLevel.assert_called_with(logging.DEBUG)


def test_truncated_formatter_preserves_shared_record():
    record = logging.LogRecord(
        "keria", logging.INFO, __file__, 42, "hello", (), None, "long_function_name"
    )
    original = record.__dict__.copy()
    keria.TruncatedFormatter("%(module)s %(funcName)s %(lineno)s %(message)s").format(
        record
    )
    assert record.__dict__ == original
    assert logging.Formatter("%(lineno)d %(message)s").format(record) == "42 hello"


if __name__ == "__main__":
    unittest.main()
