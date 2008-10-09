Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m996dBxb017308
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Oct 2008 15:39:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B5122AC028
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:39:11 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E470E12C048
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:39:10 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id C6AFC1DB803B
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:39:10 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 8776D1DB803E
	for <linux-mm@kvack.org>; Thu,  9 Oct 2008 15:39:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm 02/Oct PATCH 1/3] adjust Quicklists field of /proc/meminfo
Message-Id: <20081009153432.DEC7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Oct 2008 15:39:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

vmscan-split-lru-lists-into-anon-file-sets.patch changed /proc/meminfo output length,
but only Quicklists: field doesn't.
(because quicklists field added after than split-lru)


example: 

$ cat /proc/meminfo

  MemTotal:        7994624 kB
  MemFree:           21376 kB
(snip)
  SUnreclaim:        78912 kB
  PageTables:      1233472 kB
  Quicklists:       7808 kB
  NFS_Unstable:          0 kB


this patch fix it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 fs/proc/proc_misc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/fs/proc/proc_misc.c
===================================================================
--- a/fs/proc/proc_misc.c
+++ b/fs/proc/proc_misc.c
@@ -195,7 +195,7 @@ static int meminfo_read_proc(char *page,
 		"SUnreclaim:     %8lu kB\n"
 		"PageTables:     %8lu kB\n"
 #ifdef CONFIG_QUICKLIST
-		"Quicklists:   %8lu kB\n"
+		"Quicklists:     %8lu kB\n"
 #endif
 		"NFS_Unstable:   %8lu kB\n"
 		"Bounce:         %8lu kB\n"



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
