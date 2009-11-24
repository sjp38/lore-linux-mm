Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id ECA9F6B0078
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 00:27:51 -0500 (EST)
Message-ID: <4B0B6EAF.80802@cn.fujitsu.com>
Date: Tue, 24 Nov 2009 13:27:11 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 5/5] perf kmem: Add help file
References: <4B0B6E44.6090106@cn.fujitsu.com>
In-Reply-To: <4B0B6E44.6090106@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add Documentation/perf-kmem.txt

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 tools/perf/Documentation/perf-kmem.txt |   44 ++++++++++++++++++++++++++++++++
 tools/perf/command-list.txt            |    1 +
 2 files changed, 45 insertions(+), 0 deletions(-)
 create mode 100644 tools/perf/Documentation/perf-kmem.txt

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
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
