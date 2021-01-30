#include "test-tool.h"
#include "cache.h"

int cmd__pager(int argc, const char **argv)
{
	if (argc > 1)
		usage("\ttest-tool pager");

	setup_pager();
	while (write_in_full(1, "y\n", 2) > 0)
		;

	return 0;
}
