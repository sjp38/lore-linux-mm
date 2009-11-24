Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 31DCB6B0083
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:56:54 -0500 (EST)
Date: Tue, 24 Nov 2009 16:55:52 GMT
From: tip-bot for Li Zefan <lizf@cn.fujitsu.com>
Reply-To: mingo@redhat.com, hpa@zytor.com, linux-kernel@vger.kernel.org,
        fweisbec@gmail.com, lizf@cn.fujitsu.com, penberg@cs.helsinki.fi,
        peterz@infradead.org, eduard.munteanu@linux360.ro, tglx@linutronix.de,
        linux-mm@kvack.org, mingo@elte.hu
In-Reply-To: <4B0B6EAF.80802@cn.fujitsu.com>
References: <4B0B6EAF.80802@cn.fujitsu.com>
Subject: [tip:perf/core] perf kmem: Add help file
Message-ID: <tip-b23d5767a5818caec8547d0bce1588b02bdecd30@git.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-tip-commits@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, hpa@zytor.com, mingo@redhat.com, penberg@cs.helsinki.fi, lizf@cn.fujitsu.com, peterz@infradead.org, eduard.munteanu@linux360.ro, fweisbec@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

Commit-ID:  b23d5767a5818caec8547d0bce1588b02bdecd30
Gitweb:     http://git.kernel.org/tip/b23d5767a5818caec8547d0bce1588b02bdecd30
Author:     Li Zefan <lizf@cn.fujitsu.com>
AuthorDate: Tue, 24 Nov 2009 13:27:11 +0800
Committer:  Ingo Molnar <mingo@elte.hu>
CommitDate: Tue, 24 Nov 2009 08:49:51 +0100

perf kmem: Add help file

Add Documentation/perf-kmem.txt

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
LKML-Reference: <4B0B6EAF.80802@cn.fujitsu.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 tools/perf/Documentation/perf-kmem.txt |   44 ++++++++++++++++++++++++++++++++
 tools/perf/command-list.txt            |    1 +
 2 files changed, 45 insertions(+), 0 deletions(-)

diff --git a/tools/perf/Documentation/perf-kmem.txt b/tools/perf/Documentation/perf-kmem.txt
new file mode 100644
index 0000000..44b0ce3
--- /dev/null
+++ b/tools/perf/Documentation/perf-kmem.txt
@@ -0,0 +1,44 @@
+perf-kmem(1)
+==============
+
+NAME
+----
+perf-kmem - Tool to trace/measure kernel memory(slab) properties
+
+SYNOPSIS
+--------
+[verse]
+'perf kmem' {record} [<options>]
+
+DESCRIPTION
+-----------
+There's two variants of perf kmem:
+
+  'perf kmem record <command>' to record the kmem events
+  of an arbitrary workload.
+
+  'perf kmem' to report kernel memory statistics.
+
+OPTIONS
+-------
+-i <file>::
+--input=<file>::
+	Select the input file (default: perf.data)
+
+--stat=<caller|alloc>::
+	Select per callsite or per allocation statistics
+
+-s <key[,key2...]>::
+--sort=<key[,key2...]>::
+	Sort the output (default: frag,hit,bytes)
+
+-l <num>::
+--line=<num>::
+	Print n lines only
+
+--raw-ip::
+	Print raw ip instead of symbol
+
+SEE ALSO
+--------
+linkperf:perf-record[1]
diff --git a/tools/perf/command-list.txt b/tools/perf/command-list.txt
index d3a6e18..02b09ea 100644
--- a/tools/perf/command-list.txt
+++ b/tools/perf/command-list.txt
@@ -14,3 +14,4 @@ perf-timechart			mainporcelain common
 perf-top			mainporcelain common
 perf-trace			mainporcelain common
 perf-probe			mainporcelain common
+perf-kmem			mainporcelain common

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
