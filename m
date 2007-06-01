Message-ID: <465FB9CD.2090000@google.com>
Date: Thu, 31 May 2007 23:16:45 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: [RFC 6/7] cpuset write fixes
References: <465FB6CF.4090801@google.com>
In-Reply-To: <465FB6CF.4090801@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@google.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Remove unneeded local variable.

Originally by Christoph Lameter <clameter@sgi.com>

Signed-off-by: Ethan Solomita <solo@google.com>

---

diff -uprN -X 0/Documentation/dontdiff 5/mm/page-writeback.c 6/mm/page-writeback.c
--- 5/mm/page-writeback.c	2007-05-30 11:37:01.000000000 -0700
+++ 6/mm/page-writeback.c	2007-05-30 11:39:25.000000000 -0700
@@ -177,7 +177,6 @@ get_dirty_limits(struct dirty_limits *dl
 	int unmapped_ratio;
 	long background;
 	long dirty;
-	unsigned long available_memory = determine_dirtyable_memory();
 	unsigned long dirtyable_memory;
 	unsigned long nr_mapped;
 	struct task_struct *tsk;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
