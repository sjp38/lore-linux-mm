Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m996g89m018593
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Oct 2008 15:42:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 866242AC025
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:42:08 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 61D0712C046
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:42:08 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 48A731DB803C
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:42:08 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 002C41DB8037
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:42:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm 02/Oct PATCH 2/3] adjust hugepage related field of /proc/meminfo
In-Reply-To: <20081009153432.DEC7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081009153432.DEC7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081009153854.DECD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Oct 2008 15:42:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

adjust hugepage related field in /proc/meminfo.
(because vmscan-split-lru-lists-into-anon-file-sets.patch changed
length of other field)


before:

CommitLimit:     6028800 kB
Committed_AS:    8685888 kB
VmallocTotal:   17592177655808 kB
VmallocUsed:       28544 kB
VmallocChunk:   17592177626816 kB
HugePages_Total:     0
HugePages_Free:      0
HugePages_Rsvd:      0
HugePages_Surp:      0
Hugepagesize:    262144 kB

after:

CommitLimit:     6028800 kB
Committed_AS:    8685888 kB
VmallocTotal:   17592177655808 kB
VmallocUsed:       28544 kB
VmallocChunk:   17592177626816 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:     262144 kB


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/hugetlb.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

Index: b/mm/hugetlb.c
===================================================================
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1459,11 +1459,11 @@ int hugetlb_report_meminfo(char *buf)
 {
 	struct hstate *h = &default_hstate;
 	return sprintf(buf,
-			"HugePages_Total: %5lu\n"
-			"HugePages_Free:  %5lu\n"
-			"HugePages_Rsvd:  %5lu\n"
-			"HugePages_Surp:  %5lu\n"
-			"Hugepagesize:    %5lu kB\n",
+			"HugePages_Total:   %5lu\n"
+			"HugePages_Free:    %5lu\n"
+			"HugePages_Rsvd:    %5lu\n"
+			"HugePages_Surp:    %5lu\n"
+			"Hugepagesize:   %8lu kB\n",
 			h->nr_huge_pages,
 			h->free_huge_pages,
 			h->resv_huge_pages,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
