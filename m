Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D5BAA6B0055
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 06:27:11 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5BAS099013054
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 11 Jun 2009 19:28:00 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C4EBB45DE4F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:27:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A539B45DE4C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:27:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 904E81DB805E
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:27:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 475561DB803F
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 19:27:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH for mmotm 4/5] adjust fields length of /proc/meminfo
In-Reply-To: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
References: <20090611192114.6D4A.A69D9226@jp.fujitsu.com>
Message-Id: <20090611192717.6D56.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 11 Jun 2009 19:27:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] adjust fields length of /proc/meminfo

This patch adjust fields of /proc/meminfo. it doesn't have any behavior
change.


<before>
$ cat /proc/meminfo
MemTotal:       32275164 kB
MemFree:        31880212 kB
Buffers:            8824 kB
Cached:           175304 kB
SwapCached:            0 kB
Active:            97236 kB
Inactive:         161336 kB
Active(anon):      75344 kB
Inactive(anon):        0 kB
Active(file):      21892 kB
Inactive(file):   161336 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       4192956 kB
SwapFree:        4192956 kB
Dirty:                 0 kB
Writeback:             0 kB
AnonPages:         74480 kB
Mapped:            28048 kB
Mapped(SwapBacked):      836 kB
Slab:              45904 kB
SReclaimable:      23460 kB
SUnreclaim:        22444 kB
PageTables:         8484 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    20330536 kB
Committed_AS:     162652 kB
VmallocTotal:   34359738367 kB
VmallocUsed:       85348 kB
VmallocChunk:   34359638395 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:        7680 kB
DirectMap2M:    33546240 kB


<after>
$ cat /proc/meminfo
MemTotal:           32275164 kB
MemFree:            32000220 kB
Buffers:                8132 kB
Cached:                81224 kB
SwapCached:                0 kB
Active:                70840 kB
Inactive:              72244 kB
Active(anon):          54492 kB
Inactive(anon):            0 kB
Active(file):          16348 kB
Inactive(file):        72244 kB
Unevictable:               0 kB
Mlocked:                   0 kB
SwapTotal:           4192956 kB
SwapFree:            4192956 kB
Dirty:                    60 kB
Writeback:                 0 kB
AnonPages:             53764 kB
Mapped:                27672 kB
Mapped(SwapBacked):      708 kB
Slab:                  41544 kB
SReclaimable:          18648 kB
SUnreclaim:            22896 kB
PageTables:             8440 kB
NFS_Unstable:              0 kB
Bounce:                    0 kB
WritebackTmp:              0 kB
CommitLimit:        20330536 kB
Committed_AS:         141696 kB
VmallocTotal:    34359738367 kB
VmallocUsed:           85348 kB
VmallocChunk:    34359638395 kB
HugePages_Total:           0
HugePages_Free:            0
HugePages_Rsvd:            0
HugePages_Surp:            0
Hugepagesize:           2048 kB
DirectMap4k:            7680 kB
DirectMap2M:        33546240 kB


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 arch/x86/mm/pageattr.c |    8 ++---
 fs/proc/meminfo.c      |   74 ++++++++++++++++++++++++-------------------------
 mm/hugetlb.c           |   10 +++---
 3 files changed, 46 insertions(+), 46 deletions(-)

Index: b/arch/x86/mm/pageattr.c
===================================================================
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -70,18 +70,18 @@ static void split_page_count(int level)
 
 void arch_report_meminfo(struct seq_file *m)
 {
-	seq_printf(m, "DirectMap4k:    %8lu kB\n",
+	seq_printf(m, "DirectMap4k:        %8lu kB\n",
 			direct_pages_count[PG_LEVEL_4K] << 2);
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
-	seq_printf(m, "DirectMap2M:    %8lu kB\n",
+	seq_printf(m, "DirectMap2M:        %8lu kB\n",
 			direct_pages_count[PG_LEVEL_2M] << 11);
 #else
-	seq_printf(m, "DirectMap4M:    %8lu kB\n",
+	seq_printf(m, "DirectMap4M:        %8lu kB\n",
 			direct_pages_count[PG_LEVEL_2M] << 12);
 #endif
 #ifdef CONFIG_X86_64
 	if (direct_gbpages)
-		seq_printf(m, "DirectMap1G:    %8lu kB\n",
+		seq_printf(m, "DirectMap1G:        %8lu kB\n",
 			direct_pages_count[PG_LEVEL_1G] << 20);
 #endif
 }
Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -53,50 +53,50 @@ static int meminfo_proc_show(struct seq_
 	 * Tagged format, for easy grepping and expansion.
 	 */
 	seq_printf(m,
-		"MemTotal:       %8lu kB\n"
-		"MemFree:        %8lu kB\n"
-		"Buffers:        %8lu kB\n"
-		"Cached:         %8lu kB\n"
-		"SwapCached:     %8lu kB\n"
-		"Active:         %8lu kB\n"
-		"Inactive:       %8lu kB\n"
-		"Active(anon):   %8lu kB\n"
-		"Inactive(anon): %8lu kB\n"
-		"Active(file):   %8lu kB\n"
-		"Inactive(file): %8lu kB\n"
-		"Unevictable:    %8lu kB\n"
-		"Mlocked:        %8lu kB\n"
+		"MemTotal:           %8lu kB\n"
+		"MemFree:            %8lu kB\n"
+		"Buffers:            %8lu kB\n"
+		"Cached:             %8lu kB\n"
+		"SwapCached:         %8lu kB\n"
+		"Active:             %8lu kB\n"
+		"Inactive:           %8lu kB\n"
+		"Active(anon):       %8lu kB\n"
+		"Inactive(anon):     %8lu kB\n"
+		"Active(file):       %8lu kB\n"
+		"Inactive(file):     %8lu kB\n"
+		"Unevictable:        %8lu kB\n"
+		"Mlocked:            %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
-		"HighTotal:      %8lu kB\n"
-		"HighFree:       %8lu kB\n"
-		"LowTotal:       %8lu kB\n"
-		"LowFree:        %8lu kB\n"
+		"HighTotal:          %8lu kB\n"
+		"HighFree:           %8lu kB\n"
+		"LowTotal:           %8lu kB\n"
+		"LowFree:            %8lu kB\n"
 #endif
 #ifndef CONFIG_MMU
-		"MmapCopy:       %8lu kB\n"
+		"MmapCopy:           %8lu kB\n"
 #endif
-		"SwapTotal:      %8lu kB\n"
-		"SwapFree:       %8lu kB\n"
-		"Dirty:          %8lu kB\n"
-		"Writeback:      %8lu kB\n"
-		"AnonPages:      %8lu kB\n"
-		"Mapped:         %8lu kB\n"
+		"SwapTotal:          %8lu kB\n"
+		"SwapFree:           %8lu kB\n"
+		"Dirty:              %8lu kB\n"
+		"Writeback:          %8lu kB\n"
+		"AnonPages:          %8lu kB\n"
+		"Mapped:             %8lu kB\n"
 		"Mapped(SwapBacked): %8lu kB\n"
-		"Slab:           %8lu kB\n"
-		"SReclaimable:   %8lu kB\n"
-		"SUnreclaim:     %8lu kB\n"
-		"PageTables:     %8lu kB\n"
+		"Slab:               %8lu kB\n"
+		"SReclaimable:       %8lu kB\n"
+		"SUnreclaim:         %8lu kB\n"
+		"PageTables:         %8lu kB\n"
 #ifdef CONFIG_QUICKLIST
-		"Quicklists:     %8lu kB\n"
+		"Quicklists:         %8lu kB\n"
 #endif
-		"NFS_Unstable:   %8lu kB\n"
-		"Bounce:         %8lu kB\n"
-		"WritebackTmp:   %8lu kB\n"
-		"CommitLimit:    %8lu kB\n"
-		"Committed_AS:   %8lu kB\n"
-		"VmallocTotal:   %8lu kB\n"
-		"VmallocUsed:    %8lu kB\n"
-		"VmallocChunk:   %8lu kB\n",
+		"NFS_Unstable:       %8lu kB\n"
+		"Bounce:             %8lu kB\n"
+		"WritebackTmp:       %8lu kB\n"
+		"CommitLimit:    %12lu kB\n"
+		"Committed_AS:   %12lu kB\n"
+		"VmallocTotal:   %12lu kB\n"
+		"VmallocUsed:    %12lu kB\n"
+		"VmallocChunk:   %12lu kB\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
Index: b/mm/hugetlb.c
===================================================================
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1565,11 +1565,11 @@ void hugetlb_report_meminfo(struct seq_f
 {
 	struct hstate *h = &default_hstate;
 	seq_printf(m,
-			"HugePages_Total:   %5lu\n"
-			"HugePages_Free:    %5lu\n"
-			"HugePages_Rsvd:    %5lu\n"
-			"HugePages_Surp:    %5lu\n"
-			"Hugepagesize:   %8lu kB\n",
+			"HugePages_Total:    %8lu\n"
+			"HugePages_Free:     %8lu\n"
+			"HugePages_Rsvd:     %8lu\n"
+			"HugePages_Surp:     %8lu\n"
+			"Hugepagesize:       %8lu kB\n",
 			h->nr_huge_pages,
 			h->free_huge_pages,
 			h->resv_huge_pages,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
