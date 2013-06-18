Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 01B7C6B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 17:32:07 -0400 (EDT)
From: Joern Engel <joern@logfs.org>
Subject: [PATCH 2/3] self-test: fix make clean
Date: Tue, 18 Jun 2013 16:02:00 -0400
Message-Id: <1371585721-28087-3-git-send-email-joern@logfs.org>
In-Reply-To: <1371585721-28087-1-git-send-email-joern@logfs.org>
References: <1371585721-28087-1-git-send-email-joern@logfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Joern Engel <joern@logfs.org>

thuge-gen was forgotten.  Fix it by removing the duplication, so we
don't get too many repeats.

Signed-off-by: Joern Engel <joern@logfs.org>
---
 tools/testing/selftests/vm/Makefile |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 7d47927..cb3f5f2 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -2,8 +2,9 @@
 
 CC = $(CROSS_COMPILE)gcc
 CFLAGS = -Wall
+BINARIES = hugepage-mmap hugepage-shm map_hugetlb thuge-gen
 
-all: hugepage-mmap hugepage-shm  map_hugetlb thuge-gen
+all: $(BINARIES)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
@@ -11,4 +12,4 @@ run_tests: all
 	@/bin/sh ./run_vmtests || (echo "vmtests: [FAIL]"; exit 1)
 
 clean:
-	$(RM) hugepage-mmap hugepage-shm  map_hugetlb
+	$(RM) $(BINARIES)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
