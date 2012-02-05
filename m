Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 513C06B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 03:15:54 -0500 (EST)
Date: Sun, 5 Feb 2012 16:15:42 +0800
From: Dave Young <dyoung@redhat.com>
Subject: [PATCH 1/3] move page-types.c from Documentation to tools/vm
Message-ID: <20120205081542.GA2245@darkstar.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com

tools/ is the better place for vm tools which are used by many people.
Moving them to tools also make them open to more users instead of hide in
Documentation folder.

This patch move page-types.c to tools/vm/page-types.c
Also add Makefile in tools/vm and fix two coding style problems of below:
a. change const arrary to 'const char * const'
b. change a space to tab for indent

Signed-off-by: Dave Young <dyoung@redhat.com>
---
 Documentation/vm/Makefile                |    2 +-
 tools/vm/Makefile                        |   11 +++++++++++
 {Documentation => tools}/vm/page-types.c |    6 +++---
 3 files changed, 15 insertions(+), 4 deletions(-)
 create mode 100644 tools/vm/Makefile
 rename {Documentation => tools}/vm/page-types.c (99%)

diff --git a/Documentation/vm/Makefile b/Documentation/vm/Makefile
index 3fa4d06..e538864 100644
--- a/Documentation/vm/Makefile
+++ b/Documentation/vm/Makefile
@@ -2,7 +2,7 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := page-types hugepage-mmap hugepage-shm map_hugetlb
+hostprogs-y := hugepage-mmap hugepage-shm map_hugetlb
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
diff --git a/tools/vm/Makefile b/tools/vm/Makefile
new file mode 100644
index 0000000..3823d4b
--- /dev/null
+++ b/tools/vm/Makefile
@@ -0,0 +1,11 @@
+# Makefile for vm tools
+
+CC = $(CROSS_COMPILE)gcc
+CFLAGS = -Wall -Wextra
+
+all: page-types
+%: %.c
+	$(CC) $(CFLAGS) -o $@ $^
+
+clean:
+	$(RM) page-types
diff --git a/Documentation/vm/page-types.c b/tools/vm/page-types.c
similarity index 99%
rename from Documentation/vm/page-types.c
rename to tools/vm/page-types.c
index 7445caa..89dd173 100644
--- a/Documentation/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -123,7 +123,7 @@
 #define BIT(name)		(1ULL << KPF_##name)
 #define BITS_COMPOUND		(BIT(COMPOUND_HEAD) | BIT(COMPOUND_TAIL))
 
-static const char *page_flag_names[] = {
+static const char * const page_flag_names[] = {
 	[KPF_LOCKED]		= "L:locked",
 	[KPF_ERROR]		= "E:error",
 	[KPF_REFERENCED]	= "R:referenced",
@@ -164,7 +164,7 @@ static const char *page_flag_names[] = {
 };
 
 
-static const char *debugfs_known_mountpoints[] = {
+static const char * const debugfs_known_mountpoints[] = {
 	"/sys/kernel/debug",
 	"/debug",
 	0,
@@ -213,7 +213,7 @@ static int		hwpoison_forget_fd;
 
 static unsigned long	total_pages;
 static unsigned long	nr_pages[HASH_SIZE];
-static uint64_t 	page_flags[HASH_SIZE];
+static uint64_t		page_flags[HASH_SIZE];
 
 
 /*
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
