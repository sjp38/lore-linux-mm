Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC9116B038D
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:37:42 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 9so108643237qkk.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:37:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p24si7409258qtf.288.2017.03.02.09.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 09:37:41 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/3] userfaultfd: selftest: vm: allow to build in vm/ directory
Date: Thu,  2 Mar 2017 18:37:38 +0100
Message-Id: <20170302173738.18994-4-aarcange@redhat.com>
In-Reply-To: <20170302173738.18994-1-aarcange@redhat.com>
References: <20170302173738.18994-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

linux/tools/testing/selftests/vm $ make
gcc -Wall -I ../../../../usr/include     compaction_test.c -lrt -o /compaction_test
/usr/lib/gcc/x86_64-pc-linux-gnu/4.9.4/../../../../x86_64-pc-linux-gnu/bin/ld:
cannot open output file /compaction_test: Permission denied
collect2: error: ld returned 1 exit status
make: *** [../lib.mk:54: /compaction_test] Error 1

Since commit a8ba798bc8ec663cf02e80b0dd770324de9bafd9 selftests/vm
build fails if run from the "selftests/vm" directory, but it works in
the selftests/ directory. It's quicker to be able to do a local
vm-only build after a tree wipe and this patch allows for it again.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 tools/testing/selftests/vm/Makefile | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
index 4cff7e7..41642ba 100644
--- a/tools/testing/selftests/vm/Makefile
+++ b/tools/testing/selftests/vm/Makefile
@@ -1,5 +1,9 @@
 # Makefile for vm selftests
 
+ifndef OUTPUT
+  OUTPUT := $(shell pwd)
+endif
+
 CFLAGS = -Wall -I ../../../../usr/include $(EXTRA_CFLAGS)
 LDLIBS = -lrt
 TEST_GEN_FILES = compaction_test

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
