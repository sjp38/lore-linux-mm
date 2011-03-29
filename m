Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2457B8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 20:55:18 -0400 (EDT)
Subject: Re: [PATCH]mmap: add alignment for some variables
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <m2oc4v18x8.fsf@firstfloor.org>
References: <1301277536.3981.27.camel@sli10-conroe>
	 <m2oc4v18x8.fsf@firstfloor.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 29 Mar 2011 08:54:14 +0800
Message-ID: <1301360054.3981.31.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Tue, 2011-03-29 at 00:55 +0800, Andi Kleen wrote:
> Shaohua Li <shaohua.li@intel.com> writes:
> 
> > Make some variables have correct alignment.
> 
> Nit: __read_mostly doesn't change alignment, just the section.
> Please fix the description. Other than that it looks good.
sure.

Make some variables have correct alignment/section to avoid cache issue.
In a workload which heavily does mmap/munmap, the variables will be used
frequently.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/mmap.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2011-03-29 08:30:12.000000000 +0800
+++ linux/mm/mmap.c	2011-03-29 08:30:54.000000000 +0800
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
