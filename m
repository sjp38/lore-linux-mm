From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 002/005](memory hotplug) align memmap to page size
Date: Thu, 03 Apr 2008 14:40:18 +0900
Message-ID: <20080403143910.D1F8.E1E9C6FF@jp.fujitsu.com>
References: <20080403140221.D1F2.E1E9C6FF@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758340AbYDCFmP@vger.kernel.org>
In-Reply-To: <20080403140221.D1F2.E1E9C6FF@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Yinghai Lu <yhlu.kernel@gmail.com>, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org


To free memmap easier, this patch aligns it to page size.
Bootmem allocater may mix some objects in one pages.
It's not good for freeing memmap of memory hot-remove.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 mm/sparse.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: current/mm/sparse.c
===================================================================
--- current.orig/mm/sparse.c	2008-04-01 20:56:45.000000000 +0900
+++ current/mm/sparse.c	2008-04-01 20:58:52.000000000 +0900
@@ -263,8 +263,8 @@
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
