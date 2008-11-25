Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAP4PvOb026114
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 25 Nov 2008 13:25:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 18A9045DE4E
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:25:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C626745DE4F
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:25:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A06271DB8038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:25:56 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 527ED1DB803F
	for <linux-mm@kvack.org>; Tue, 25 Nov 2008 13:25:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] mm: make maddr __iomem 
In-Reply-To: <20081125131942.26CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081125131942.26CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081125132501.26D3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 25 Nov 2008 13:25:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

sparse output following warnings.

mm/memory.c:2936:8: warning: incorrect type in assignment (different address spaces)
mm/memory.c:2936:8:    expected void *maddr
mm/memory.c:2936:8:    got void [noderef] <asn:2>


cleanup here.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/memory.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/mm/memory.c
===================================================================
--- a/mm/memory.c	2008-11-05 01:11:44.000000000 +0900
+++ b/mm/memory.c	2008-11-22 21:56:31.000000000 +0900
@@ -2922,7 +2922,7 @@ int generic_access_phys(struct vm_area_s
 {
 	resource_size_t phys_addr;
 	unsigned long prot = 0;
-	void *maddr;
+	void __iomem *maddr;
 	int offset = addr & (PAGE_SIZE-1);
 
 	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP)))


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
