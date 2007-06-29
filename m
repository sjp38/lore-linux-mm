Received: from sd0112e0.au.ibm.com (d23rh903.au.ibm.com [202.81.18.201])
	by ausmtp06.au.ibm.com (8.13.8/8.13.8) with ESMTP id l5T6PUAC5103690
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:25:31 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0112e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5T6RlKS081456
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:27:57 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5T6MXK3021002
	for <linux-mm@kvack.org>; Fri, 29 Jun 2007 16:22:52 +1000
Message-ID: <4684A523.5090600@linux.vnet.ibm.com>
Date: Fri, 29 Jun 2007 11:52:27 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 3/3] Pagecache reclaim
References: <4684A3F3.40001@linux.vnet.ibm.com>
In-Reply-To: <4684A3F3.40001@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@in.ibm.com>, Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>, Roy Huang <royhuang9@gmail.com>, Aubrey Li <aubreylee@gmail.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Pagecache controller reclaim changes
------------------------------------

Reclaim path needs performance improvement.
For now it is minor changes to include unmapped
pages in our list of page_container.

Signed-off-by: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
---
 mm/rss_container.c |    3 ---
 1 file changed, 3 deletions(-)

--- linux-2.6.22-rc2-mm1.orig/mm/rss_container.c
+++ linux-2.6.22-rc2-mm1/mm/rss_container.c
@@ -243,9 +243,6 @@ void container_rss_move_lists(struct pag
 	struct rss_container *rss;
 	struct page_container *pc;

-	if (!page_mapped(pg))
-		return;
-
 	pc = page_container(pg);
 	if (pc == NULL)
 		return;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
