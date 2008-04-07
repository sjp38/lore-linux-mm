From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 002/005](memory hotplug) align memmap to page size
Date: Mon, 07 Apr 2008 21:46:19 +0900
Message-ID: <20080407214514.8872.E1E9C6FF@jp.fujitsu.com>
References: <20080407213519.886E.E1E9C6FF@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758480AbYDGMuU@vger.kernel.org>
In-Reply-To: <20080407213519.886E.E1E9C6FF@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Yinghai Lu <yhlu.kernel@gmail.com>
List-Id: linux-mm.kvack.org


To free memmap easier, this patch aligns it to page size.
Bootmem allocater may mix some objects in one pages.
It's not good for freeing memmap of memory hot-remove.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 mm/sparse.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: current/mm/sparse.c
===================================================================
--- current.orig/mm/sparse.c	2008-04-07 19:18:50.000000000 +0900
+++ current/mm/sparse.c	2008-04-07 20:08:13.000000000 +0900
@@ -265,8 +265,8 @@
 	if (map)
 		return map;
 
-	map = alloc_bootmem_node(NODE_DATA(nid),
-			sizeof(struct page) * PAGES_PER_SECTION);
+	map = alloc_bootmem_pages_node(NODE_DATA(nid),
+		       PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION));
 	return map;
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */

-- 
Yasunori Goto 
