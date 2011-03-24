Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EBA3E8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:53:32 -0400 (EDT)
Date: Thu, 24 Mar 2011 13:53:16 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: +
 ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages.patch
 added to -mm tree
Message-ID: <20110324125316.GA2310@cmpxchg.org>
References: <201103012341.p21Nf64e006469@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201103012341.p21Nf64e006469@imap1.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: nai.xia@gmail.com, aarcange@redhat.com, chrisw@sous-sol.org, hugh.dickins@tiscali.co.uk, ieidus@redhat.com, riel@redhat.com, mm-commits@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 01, 2011 at 03:41:06PM -0800, akpm@linux-foundation.org wrote:
> diff -puN include/linux/mmzone.h~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages include/linux/mmzone.h
> --- a/include/linux/mmzone.h~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages
> +++ a/include/linux/mmzone.h
> @@ -115,6 +115,9 @@ enum zone_stat_item {
>  	NUMA_OTHER,		/* allocation from other node */
>  #endif
>  	NR_ANON_TRANSPARENT_HUGEPAGES,
> +#ifdef CONFIG_KSM
> +	NR_KSM_PAGES_SHARING,
> +#endif
>  	NR_VM_ZONE_STAT_ITEMS };

This adds a zone stat item without a corresponding entry in
vm_stat_text.  As a result, all vm event entries in /proc/vmstat show
the value of the respective previous counter.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 5ce2d0a..fca991c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -886,6 +886,9 @@ static const char * const vmstat_text[] = {
 	"numa_other",
 #endif
 	"nr_anon_transparent_hugepages",
+#ifdef CONFIG_KSM
+	"nr_ksm_pages_sharing",
+#endif
 	"nr_dirty_threshold",
 	"nr_dirty_background_threshold",
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
