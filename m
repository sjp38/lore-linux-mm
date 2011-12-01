Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BCE376B0047
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 16:41:28 -0500 (EST)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: [PATCH 01/11] mm: export vmalloc_sync_all symbol to GPL modules
Date: Thu,  1 Dec 2011 16:41:13 -0500
Message-Id: <1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
In-Reply-To: <1322775683-8741-1-git-send-email-mathieu.desnoyers@efficios.com>
References: <1322775683-8741-1-git-send-email-mathieu.desnoyers@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <greg@kroah.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: devel@driverdev.osuosl.org, lttng-dev@lists.lttng.org, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, David McCullough <davidm@snapgear.com>, D Jeff Dionne <jeff@uClinux.org>, Greg Ungerer <gerg@snapgear.com>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

LTTng needs this symbol exported. It calls it to ensure its tracing
buffers and allocated data structures never trigger a page fault. This
is required to handle page fault handler tracing and NMI tracing
gracefully.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>
CC: Christoph Hellwig <hch@infradead.org>
CC: Christoph Lameter <cl@linux-foundation.org>
CC: Tejun Heo <tj@kernel.org>
CC: David Howells <dhowells@redhat.com>
CC: David McCullough <davidm@snapgear.com>
CC: D Jeff Dionne <jeff@uClinux.org>
CC: Greg Ungerer <gerg@snapgear.com>
CC: Paul Mundt <lethal@linux-sh.org>
CC: linux-mm@kvack.org
CC: linux-kernel@vger.kernel.org
CC: Greg KH <greg@kroah.com>
---
 mm/nommu.c   |    1 +
 mm/vmalloc.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index b982290..b22a0d9 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -441,6 +441,7 @@ EXPORT_SYMBOL_GPL(vm_unmap_aliases);
 void  __attribute__((weak)) vmalloc_sync_all(void)
 {
 }
+EXPORT_SYMBOL_GPL(vmalloc_sync_all);
 
 /**
  *	alloc_vm_area - allocate a range of kernel address space
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 3231bf3..37ddce5 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2137,6 +2137,7 @@ EXPORT_SYMBOL(remap_vmalloc_range);
 void  __attribute__((weak)) vmalloc_sync_all(void)
 {
 }
+EXPORT_SYMBOL_GPL(vmalloc_sync_all);
 
 
 static int f(pte_t *pte, pgtable_t table, unsigned long addr, void *data)
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
