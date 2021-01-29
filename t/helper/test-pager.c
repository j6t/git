#include "test-tool.h"
#include "cache.h"

int cmd__pager(int argc, const char **argv)
{
	if (argc > 1)
		usage("\ttest-tool pager");

	setup_pager();
	for (;;)
		puts("y");
}
