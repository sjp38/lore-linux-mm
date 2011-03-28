Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 5411F8D0041
	for <linux-mm@kvack.org>; Sun, 27 Mar 2011 22:03:58 -0400 (EDT)
Subject: [PATCH]mmap: add alignment for some variables
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Mar 2011 09:58:56 +0800
Message-ID: <1301277536.3981.27.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

Make some variables have correct alignment.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/mmap.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2011-03-24 10:59:39.000000000 +0800
+++ linux/mm/mmap.c	2011-03-24 10:59:42.000000000 +0800
@@ -84,10 +84,10 @@ pgprot_t vm_get_page_prot(unsigned long
 }
 EXPORT_SYMBOL(vm_get_page_prot);
 
-int sysctl_overcommit_memory = OVERCOMMIT_GUESS;  /* heuristic overcommit */
-int sysctl_overcommit_ratio = 50;	/* default is 50% */
+int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
+int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
-struct percpu_counter vm_committed_as;
+struct percpu_counter vm_committed_as ____cacheline_internodealigned_in_smp;
 
 /*
  * Check that a process has enough memory to allocate a new virtual


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
