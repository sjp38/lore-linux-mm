Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 966F86B009F
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 03:55:35 -0500 (EST)
Date: Fri, 20 Nov 2009 08:54:50 GMT
From: tip-bot for Li Zefan <lizf@cn.fujitsu.com>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        lizf@cn.fujitsu.com, penberg@cs.helsinki.fi, peterz@infradead.org,
        eduard.munteanu@linux360.ro, fweisbec@gmail.com, rostedt@goodmis.org,
        tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <4B064AF5.9060208@cn.fujitsu.com>
References: <4B064AF5.9060208@cn.fujitsu.com>
Subject: [tip:perf/core] perf: Add 'perf kmem' tool
Message-ID: <tip-ba77c9e11111a172c9e8687fe16a6a173a61916f@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, penberg@cs.helsinki.fi, lizf@cn.fujitsu.com, peterz@infradead.org, eduard.munteanu@linux360.ro, fweisbec@gmail.com, rostedt@goodmis.org, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Commit-ID:  ba77c9e11111a172c9e8687fe16a6a173a61916f
Gitweb:     http://git.kernel.org/tip/ba77c9e11111a172c9e8687fe16a6a173a61916f
Author:     Li Zefan <lizf@cn.fujitsu.com>
AuthorDate: Fri, 20 Nov 2009 15:53:25 +0800
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Fri, 20 Nov 2009 09:51:41 +0100

perf: Add 'perf kmem' tool

This tool is mostly a perf version of kmemtrace-user.

The following information is provided by this tool:

 - the total amount of memory allocated and fragmentation per
   call-site

 - the total amount of memory allocated and fragmentation per
   allocation

 - total memory allocated and fragmentation in the collected
   dataset - ...

Sample output:

 # ./perf kmem record
 ^C
 # ./perf kmem --stat caller --stat alloc -l 10

 ------------------------------------------------------------------------------
 Callsite          | Total_alloc/Per |  Total_req/Per  |  Hit   | Fragmentation
 ------------------------------------------------------------------------------
 0xc052f37a        |   790528/4096   |   790528/4096   |    193 |    0.000%
 0xc0541d70        |   524288/4096   |   524288/4096   |    128 |    0.000%
 0xc051cc68        |   481600/200    |   481600/200    |   2408 |    0.000%
 0xc0572623        |   297444/676    |   297440/676    |    440 |    0.001%
 0xc05399f1        |    73476/164    |    73472/164    |    448 |    0.005%
 0xc05243bf        |    51456/256    |    51456/256    |    201 |    0.000%
 0xc0730d0e        |    31844/497    |    31808/497    |     64 |    0.113%
 0xc0734c4e        |    17152/256    |    17152/256    |     67 |    0.000%
 0xc0541a6d        |    16384/128    |    16384/128    |    128 |    0.000%
 0xc059c217        |    13120/40     |    13120/40     |    328 |    0.000%
 0xc0501ee6        |    11264/88     |    11264/88     |    128 |    0.000%
 0xc04daef0        |     7504/682    |     7128/648    |     11 |    5.011%
 0xc04e14a3        |     4216/191    |     4216/191    |     22 |    0.000%
 0xc05041ca        |     3524/44     |     3520/44     |     80 |    0.114%
 0xc0734fa3        |     2104/701    |     1620/540    |      3 |   23.004%
 0xc05ec9f1        |     2024/289    |     2016/288    |      7 |    0.395%
 0xc06a1999        |     1792/256    |     1792/256    |      7 |    0.000%
 0xc0463b9a        |     1584/144    |     1584/144    |     11 |    0.000%
 0xc0541eb0        |     1024/16     |     1024/16     |     64 |    0.000%
 0xc06a19ac        |      896/128    |      896/128    |      7 |    0.000%
 0xc05721c0        |      772/12     |      768/12     |     64 |    0.518%
 0xc054d1e6        |      288/57     |      280/56     |      5 |    2.778%
 0xc04b562e        |      157/31     |      154/30     |      5 |    1.911%
 0xc04b536f        |       80/16     |       80/16     |      5 |    0.000%
 0xc05855a0        |       64/64     |       36/36     |      1 |   43.750%
 ------------------------------------------------------------------------------

 ------------------------------------------------------------------------------
 Alloc Ptr         | Total_alloc/Per |  Total_req/Per  |  Hit   | Fragmentation
 ------------------------------------------------------------------------------
 0xda884000        |  1052672/4096   |  1052672/4096   |    257 |    0.000%
 0xda886000        |   262144/4096   |   262144/4096   |     64 |    0.000%
 0xf60c7c00        |    16512/128    |    16512/128    |    129 |    0.000%
 0xf59a4118        |    13120/40     |    13120/40     |    328 |    0.000%
 0xdfd4b2c0        |    11264/88     |    11264/88     |    128 |    0.000%
 0xf5274600        |     7680/256    |     7680/256    |     30 |    0.000%
 0xe8395000        |     5948/594    |     5464/546    |     10 |    8.137%
 0xe59c3c00        |     5748/479    |     5712/476    |     12 |    0.626%
 0xf4cd1a80        |     3524/44     |     3520/44     |     80 |    0.114%
 0xe5bd1600        |     2892/482    |     2856/476    |      6 |    1.245%
 ...               | ...             | ...             | ...    | ...
 ------------------------------------------------------------------------------

SUMMARY
=======
Total bytes requested: 2333626
Total bytes allocated: 2353712
Total bytes wasted on internal fragmentation: 20086
Internal fragmentation: 0.853375%

TODO:
- show sym+offset in 'callsite' column
- show cross node allocation stats
- collect more useful stats?
- ...

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Acked-by: Peter Zijlstra <peterz@infradead.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
LKML-Reference: <4B064AF5.9060208@cn.fujitsu.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 tools/perf/Makefile       |    1 +
 tools/perf/builtin-kmem.c |  578 +++++++++++++++++++++++++++++++++++++++++++++
 tools/perf/builtin.h      |    1 +
 tools/perf/perf.c         |   27 +-
 4 files changed, 594 insertions(+), 13 deletions(-)

diff --git a/tools/perf/Makefile b/tools/perf/Makefile
index 3f0666a..d7198c5 100644
--- a/tools/perf/Makefile
+++ b/tools/perf/Makefile
@@ -444,6 +444,7 @@ BUILTIN_OBJS += builtin-timechart.o
 BUILTIN_OBJS += builtin-top.o
 BUILTIN_OBJS += builtin-trace.o
 BUILTIN_OBJS += builtin-probe.o
+BUILTIN_OBJS += builtin-kmem.o
 
 PERFLIBS = $(LIB_FILE)
 
diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
new file mode 100644
index 0000000..f315b05
--- /dev/null
+++ b/tools/perf/builtin-kmem.c
@@ -0,0 +1,578 @@
+#include "builtin.h"
+#include "perf.h"
+
+#include "util/util.h"
+#include "util/cache.h"
+#include "util/symbol.h"
+#include "util/thread.h"
+#include "util/header.h"
+
+#include "util/parse-options.h"
+#include "util/trace-event.h"
+
+#include "util/debug.h"
+#include "util/data_map.h"
+
+#include <linux/rbtree.h>
+
+struct alloc_stat;
+typedef int (*sort_fn_t)(struct alloc_stat *, struct alloc_stat *);
+
+static char const		*input_name = "perf.data";
+
+static struct perf_header	*header;
+static u64			sample_type;
+
+static int			alloc_flag;
+static int			caller_flag;
+
+sort_fn_t			alloc_sort_fn;
+sort_fn_t			caller_sort_fn;
+
+static int			alloc_lines = -1;
+static int			caller_lines = -1;
+
+static char			*cwd;
+static int			cwdlen;
+
+struct alloc_stat {
+	union {
+		struct {
+			char	*name;
+			u64	call_site;
+		};
+		u64	ptr;
+	};
+	u64	bytes_req;
+	u64	bytes_alloc;
+	u32	hit;
+
+	struct rb_node node;
+};
+
+static struct rb_root root_alloc_stat;
+static struct rb_root root_alloc_sorted;
+static struct rb_root root_caller_stat;
+static struct rb_root root_caller_sorted;
+
+static unsigned long total_requested, total_allocated;
+
+struct raw_event_sample {
+	u32 size;
+	char data[0];
+};
+
+static int
+process_comm_event(event_t *event, unsigned long offset, unsigned long head)
+{
+	struct thread *thread = threads__findnew(event->comm.pid);
+
+	dump_printf("%p [%p]: PERF_RECORD_COMM: %s:%d\n",
+		(void *)(offset + head),
+		(void *)(long)(event->header.size),
+		event->comm.comm, event->comm.pid);
+
+	if (thread == NULL ||
+	    thread__set_comm(thread, event->comm.comm)) {
+		dump_printf("problem processing PERF_RECORD_COMM, skipping event.\n");
+		return -1;
+	}
+
+	return 0;
+}
+
+static void insert_alloc_stat(unsigned long ptr,
+			      int bytes_req, int bytes_alloc)
+{
+	struct rb_node **node = &root_alloc_stat.rb_node;
+	struct rb_node *parent = NULL;
+	struct alloc_stat *data = NULL;
+
+	if (!alloc_flag)
+		return;
+
+	while (*node) {
+		parent = *node;
+		data = rb_entry(*node, struct alloc_stat, node);
+
+		if (ptr > data->ptr)
+			node = &(*node)->rb_right;
+		else if (ptr < data->ptr)
+			node = &(*node)->rb_left;
+		else
+			break;
+	}
+
+	if (data && data->ptr == ptr) {
+		data->hit++;
+		data->bytes_req += bytes_req;
+		data->bytes_alloc += bytes_req;
+	} else {
+		data = malloc(sizeof(*data));
+		data->ptr = ptr;
+		data->hit = 1;
+		data->bytes_req = bytes_req;
+		data->bytes_alloc = bytes_alloc;
+
+		rb_link_node(&data->node, parent, node);
+		rb_insert_color(&data->node, &root_alloc_stat);
+	}
+}
+
+static void insert_caller_stat(unsigned long call_site,
+			      int bytes_req, int bytes_alloc)
+{
+	struct rb_node **node = &root_caller_stat.rb_node;
+	struct rb_node *parent = NULL;
+	struct alloc_stat *data = NULL;
+
+	if (!caller_flag)
+		return;
+
+	while (*node) {
+		parent = *node;
+		data = rb_entry(*node, struct alloc_stat, node);
+
+		if (call_site > data->call_site)
+			node = &(*node)->rb_right;
+		else if (call_site < data->call_site)
+			node = &(*node)->rb_left;
+		else
+			break;
+	}
+
+	if (data && data->call_site == call_site) {
+		data->hit++;
+		data->bytes_req += bytes_req;
+		data->bytes_alloc += bytes_req;
+	} else {
+		data = malloc(sizeof(*data));
+		data->call_site = call_site;
+		data->hit = 1;
+		data->bytes_req = bytes_req;
+		data->bytes_alloc = bytes_alloc;
+
+		rb_link_node(&data->node, parent, node);
+		rb_insert_color(&data->node, &root_caller_stat);
+	}
+}
+
+static void process_alloc_event(struct raw_event_sample *raw,
+				struct event *event,
+				int cpu __used,
+				u64 timestamp __used,
+				struct thread *thread __used,
+				int node __used)
+{
+	unsigned long call_site;
+	unsigned long ptr;
+	int bytes_req;
+	int bytes_alloc;
+
+	ptr = raw_field_value(event, "ptr", raw->data);
+	call_site = raw_field_value(event, "call_site", raw->data);
+	bytes_req = raw_field_value(event, "bytes_req", raw->data);
+	bytes_alloc = raw_field_value(event, "bytes_alloc", raw->data);
+
+	insert_alloc_stat(ptr, bytes_req, bytes_alloc);
+	insert_caller_stat(call_site, bytes_req, bytes_alloc);
+
+	total_requested += bytes_req;
+	total_allocated += bytes_alloc;
+}
+
+static void process_free_event(struct raw_event_sample *raw __used,
+			       struct event *event __used,
+			       int cpu __used,
+			       u64 timestamp __used,
+			       struct thread *thread __used)
+{
+}
+
+static void
+process_raw_event(event_t *raw_event __used, void *more_data,
+		  int cpu, u64 timestamp, struct thread *thread)
+{
+	struct raw_event_sample *raw = more_data;
+	struct event *event;
+	int type;
+
+	type = trace_parse_common_type(raw->data);
+	event = trace_find_event(type);
+
+	if (!strcmp(event->name, "kmalloc") ||
+	    !strcmp(event->name, "kmem_cache_alloc")) {
+		process_alloc_event(raw, event, cpu, timestamp, thread, 0);
+		return;
+	}
+
+	if (!strcmp(event->name, "kmalloc_node") ||
+	    !strcmp(event->name, "kmem_cache_alloc_node")) {
+		process_alloc_event(raw, event, cpu, timestamp, thread, 1);
+		return;
+	}
+
+	if (!strcmp(event->name, "kfree") ||
+	    !strcmp(event->name, "kmem_cache_free")) {
+		process_free_event(raw, event, cpu, timestamp, thread);
+		return;
+	}
+}
+
+static int
+process_sample_event(event_t *event, unsigned long offset, unsigned long head)
+{
+	u64 ip = event->ip.ip;
+	u64 timestamp = -1;
+	u32 cpu = -1;
+	u64 period = 1;
+	void *more_data = event->ip.__more_data;
+	struct thread *thread = threads__findnew(event->ip.pid);
+
+	if (sample_type & PERF_SAMPLE_TIME) {
+		timestamp = *(u64 *)more_data;
+		more_data += sizeof(u64);
+	}
+
+	if (sample_type & PERF_SAMPLE_CPU) {
+		cpu = *(u32 *)more_data;
+		more_data += sizeof(u32);
+		more_data += sizeof(u32); /* reserved */
+	}
+
+	if (sample_type & PERF_SAMPLE_PERIOD) {
+		period = *(u64 *)more_data;
+		more_data += sizeof(u64);
+	}
+
+	dump_printf("%p [%p]: PERF_RECORD_SAMPLE (IP, %d): %d/%d: %p period: %Ld\n",
+		(void *)(offset + head),
+		(void *)(long)(event->header.size),
+		event->header.misc,
+		event->ip.pid, event->ip.tid,
+		(void *)(long)ip,
+		(long long)period);
+
+	if (thread == NULL) {
+		pr_debug("problem processing %d event, skipping it.\n",
+			 event->header.type);
+		return -1;
+	}
+
+	dump_printf(" ... thread: %s:%d\n", thread->comm, thread->pid);
+
+	process_raw_event(event, more_data, cpu, timestamp, thread);
+
+	return 0;
+}
+
+static int sample_type_check(u64 type)
+{
+	sample_type = type;
+
+	if (!(sample_type & PERF_SAMPLE_RAW)) {
+		fprintf(stderr,
+			"No trace sample to read. Did you call perf record "
+			"without -R?");
+		return -1;
+	}
+
+	return 0;
+}
+
+static struct perf_file_handler file_handler = {
+	.process_sample_event	= process_sample_event,
+	.process_comm_event	= process_comm_event,
+	.sample_type_check	= sample_type_check,
+};
+
+static int read_events(void)
+{
+	register_idle_thread();
+	register_perf_file_handler(&file_handler);
+
+	return mmap_dispatch_perf_file(&header, input_name, 0, 0,
+				       &cwdlen, &cwd);
+}
+
+static double fragmentation(unsigned long n_req, unsigned long n_alloc)
+{
+	if (n_alloc == 0)
+		return 0.0;
+	else
+		return 100.0 - (100.0 * n_req / n_alloc);
+}
+
+static void __print_result(struct rb_root *root, int n_lines, int is_caller)
+{
+	struct rb_node *next;
+
+	printf("\n ------------------------------------------------------------------------------\n");
+	if (is_caller)
+		printf(" Callsite          |");
+	else
+		printf(" Alloc Ptr         |");
+	printf(" Total_alloc/Per |  Total_req/Per  |  Hit   | Fragmentation\n");
+	printf(" ------------------------------------------------------------------------------\n");
+
+	next = rb_first(root);
+
+	while (next && n_lines--) {
+		struct alloc_stat *data;
+
+		data = rb_entry(next, struct alloc_stat, node);
+
+		printf(" %-16p  | %8llu/%-6lu | %8llu/%-6lu | %6lu | %8.3f%%\n",
+		       is_caller ? (void *)(unsigned long)data->call_site :
+				   (void *)(unsigned long)data->ptr,
+		       (unsigned long long)data->bytes_alloc,
+		       (unsigned long)data->bytes_alloc / data->hit,
+		       (unsigned long long)data->bytes_req,
+		       (unsigned long)data->bytes_req / data->hit,
+		       (unsigned long)data->hit,
+		       fragmentation(data->bytes_req, data->bytes_alloc));
+
+		next = rb_next(next);
+	}
+
+	if (n_lines == -1)
+		printf(" ...               | ...             | ...             | ...    | ...   \n");
+
+	printf(" ------------------------------------------------------------------------------\n");
+}
+
+static void print_summary(void)
+{
+	printf("\nSUMMARY\n=======\n");
+	printf("Total bytes requested: %lu\n", total_requested);
+	printf("Total bytes allocated: %lu\n", total_allocated);
+	printf("Total bytes wasted on internal fragmentation: %lu\n",
+	       total_allocated - total_requested);
+	printf("Internal fragmentation: %f%%\n",
+	       fragmentation(total_requested, total_allocated));
+}
+
+static void print_result(void)
+{
+	if (caller_flag)
+		__print_result(&root_caller_sorted, caller_lines, 1);
+	if (alloc_flag)
+		__print_result(&root_alloc_sorted, alloc_lines, 0);
+	print_summary();
+}
+
+static void sort_insert(struct rb_root *root, struct alloc_stat *data,
+			sort_fn_t sort_fn)
+{
+	struct rb_node **new = &(root->rb_node);
+	struct rb_node *parent = NULL;
+
+	while (*new) {
+		struct alloc_stat *this;
+		int cmp;
+
+		this = rb_entry(*new, struct alloc_stat, node);
+		parent = *new;
+
+		cmp = sort_fn(data, this);
+
+		if (cmp > 0)
+			new = &((*new)->rb_left);
+		else
+			new = &((*new)->rb_right);
+	}
+
+	rb_link_node(&data->node, parent, new);
+	rb_insert_color(&data->node, root);
+}
+
+static void __sort_result(struct rb_root *root, struct rb_root *root_sorted,
+			  sort_fn_t sort_fn)
+{
+	struct rb_node *node;
+	struct alloc_stat *data;
+
+	for (;;) {
+		node = rb_first(root);
+		if (!node)
+			break;
+
+		rb_erase(node, root);
+		data = rb_entry(node, struct alloc_stat, node);
+		sort_insert(root_sorted, data, sort_fn);
+	}
+}
+
+static void sort_result(void)
+{
+	__sort_result(&root_alloc_stat, &root_alloc_sorted, alloc_sort_fn);
+	__sort_result(&root_caller_stat, &root_caller_sorted, caller_sort_fn);
+}
+
+static int __cmd_kmem(void)
+{
+	setup_pager();
+	read_events();
+	sort_result();
+	print_result();
+
+	return 0;
+}
+
+static const char * const kmem_usage[] = {
+	"perf kmem [<options>] {record}",
+	NULL
+};
+
+
+static int ptr_cmp(struct alloc_stat *l, struct alloc_stat *r)
+{
+	if (l->ptr < r->ptr)
+		return -1;
+	else if (l->ptr > r->ptr)
+		return 1;
+	return 0;
+}
+
+static int callsite_cmp(struct alloc_stat *l, struct alloc_stat *r)
+{
+	if (l->call_site < r->call_site)
+		return -1;
+	else if (l->call_site > r->call_site)
+		return 1;
+	return 0;
+}
+
+static int bytes_cmp(struct alloc_stat *l, struct alloc_stat *r)
+{
+	if (l->bytes_alloc < r->bytes_alloc)
+		return -1;
+	else if (l->bytes_alloc > r->bytes_alloc)
+		return 1;
+	return 0;
+}
+
+static int parse_sort_opt(const struct option *opt __used,
+			  const char *arg, int unset __used)
+{
+	sort_fn_t sort_fn;
+
+	if (!arg)
+		return -1;
+
+	if (strcmp(arg, "ptr") == 0)
+		sort_fn = ptr_cmp;
+	else if (strcmp(arg, "call_site") == 0)
+		sort_fn = callsite_cmp;
+	else if (strcmp(arg, "bytes") == 0)
+		sort_fn = bytes_cmp;
+	else
+		return -1;
+
+	if (caller_flag > alloc_flag)
+		caller_sort_fn = sort_fn;
+	else
+		alloc_sort_fn = sort_fn;
+
+	return 0;
+}
+
+static int parse_stat_opt(const struct option *opt __used,
+			  const char *arg, int unset __used)
+{
+	if (!arg)
+		return -1;
+
+	if (strcmp(arg, "alloc") == 0)
+		alloc_flag = (caller_flag + 1);
+	else if (strcmp(arg, "caller") == 0)
+		caller_flag = (alloc_flag + 1);
+	else
+		return -1;
+	return 0;
+}
+
+static int parse_line_opt(const struct option *opt __used,
+			  const char *arg, int unset __used)
+{
+	int lines;
+
+	if (!arg)
+		return -1;
+
+	lines = strtoul(arg, NULL, 10);
+
+	if (caller_flag > alloc_flag)
+		caller_lines = lines;
+	else
+		alloc_lines = lines;
+
+	return 0;
+}
+
+static const struct option kmem_options[] = {
+	OPT_STRING('i', "input", &input_name, "file",
+		   "input file name"),
+	OPT_CALLBACK(0, "stat", NULL, "<alloc>|<caller>",
+		     "stat selector, Pass 'alloc' or 'caller'.",
+		     parse_stat_opt),
+	OPT_CALLBACK('s', "sort", NULL, "key",
+		     "sort by key: ptr, call_site, hit, bytes",
+		     parse_sort_opt),
+	OPT_CALLBACK('l', "line", NULL, "num",
+		     "show n lins",
+		     parse_line_opt),
+	OPT_END()
+};
+
+static const char *record_args[] = {
+	"record",
+	"-a",
+	"-R",
+	"-M",
+	"-f",
+	"-c", "1",
+	"-e", "kmem:kmalloc",
+	"-e", "kmem:kmalloc_node",
+	"-e", "kmem:kfree",
+	"-e", "kmem:kmem_cache_alloc",
+	"-e", "kmem:kmem_cache_alloc_node",
+	"-e", "kmem:kmem_cache_free",
+};
+
+static int __cmd_record(int argc, const char **argv)
+{
+	unsigned int rec_argc, i, j;
+	const char **rec_argv;
+
+	rec_argc = ARRAY_SIZE(record_args) + argc - 1;
+	rec_argv = calloc(rec_argc + 1, sizeof(char *));
+
+	for (i = 0; i < ARRAY_SIZE(record_args); i++)
+		rec_argv[i] = strdup(record_args[i]);
+
+	for (j = 1; j < (unsigned int)argc; j++, i++)
+		rec_argv[i] = argv[j];
+
+	return cmd_record(i, rec_argv, NULL);
+}
+
+int cmd_kmem(int argc, const char **argv, const char *prefix __used)
+{
+	symbol__init(0);
+
+	argc = parse_options(argc, argv, kmem_options, kmem_usage, 0);
+
+	if (argc && !strncmp(argv[0], "rec", 3))
+		return __cmd_record(argc, argv);
+	else if (argc)
+		usage_with_options(kmem_usage, kmem_options);
+
+	if (!alloc_sort_fn)
+		alloc_sort_fn = bytes_cmp;
+	if (!caller_sort_fn)
+		caller_sort_fn = bytes_cmp;
+
+	return __cmd_kmem();
+}
+
diff --git a/tools/perf/builtin.h b/tools/perf/builtin.h
index 9b02d85..a3d8bf6 100644
--- a/tools/perf/builtin.h
+++ b/tools/perf/builtin.h
@@ -28,5 +28,6 @@ extern int cmd_top(int argc, const char **argv, const char *prefix);
 extern int cmd_trace(int argc, const char **argv, const char *prefix);
 extern int cmd_version(int argc, const char **argv, const char *prefix);
 extern int cmd_probe(int argc, const char **argv, const char *prefix);
+extern int cmd_kmem(int argc, const char **argv, const char *prefix);
 
 #endif
diff --git a/tools/perf/perf.c b/tools/perf/perf.c
index 89b82ac..cf64049 100644
--- a/tools/perf/perf.c
+++ b/tools/perf/perf.c
@@ -285,20 +285,21 @@ static void handle_internal_command(int argc, const char **argv)
 {
 	const char *cmd = argv[0];
 	static struct cmd_struct commands[] = {
-		{ "help", cmd_help, 0 },
-		{ "list", cmd_list, 0 },
 		{ "buildid-list", cmd_buildid_list, 0 },
-		{ "record", cmd_record, 0 },
-		{ "report", cmd_report, 0 },
-		{ "bench", cmd_bench, 0 },
-		{ "stat", cmd_stat, 0 },
-		{ "timechart", cmd_timechart, 0 },
-		{ "top", cmd_top, 0 },
-		{ "annotate", cmd_annotate, 0 },
-		{ "version", cmd_version, 0 },
-		{ "trace", cmd_trace, 0 },
-		{ "sched", cmd_sched, 0 },
-		{ "probe", cmd_probe, 0 },
+		{ "help",	cmd_help,	0 },
+		{ "list",	cmd_list,	0 },
+		{ "record",	cmd_record,	0 },
+		{ "report",	cmd_report,	0 },
+		{ "bench",	cmd_bench,	0 },
+		{ "stat",	cmd_stat,	0 },
+		{ "timechart",	cmd_timechart,	0 },
+		{ "top",	cmd_top,	0 },
+		{ "annotate",	cmd_annotate,	0 },
+		{ "version",	cmd_version,	0 },
+		{ "trace",	cmd_trace,	0 },
+		{ "sched",	cmd_sched,	0 },
+		{ "probe",	cmd_probe,	0 },
+		{ "kmem",	cmd_kmem,	0 },
 	};
 	unsigned int i;
 	static const char ext[] = STRIP_EXTENSION;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
