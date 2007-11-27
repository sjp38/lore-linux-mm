Date: Tue, 27 Nov 2007 11:59:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][for -mm] per-zone and reclaim enhancements for memory
 controller take 3 [2/10] nid/zid helper function for cgroup
Message-Id: <20071127115914.cf20f5b2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20071127115525.e9779108.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071127115525.e9779108.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Add macro to get node_id and zone_id of page_cgroup.
Will be used in per-zone-xxx patches and others.

Changelog:
 - returns zone_type instead of int.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 mm/memcontrol.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-2.6.24-rc3-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.24-rc3-mm1.orig/mm/memcontrol.c	2007-11-26 15:31:19.000000000 +0900
+++ linux-2.6.24-rc3-mm1/mm/memcontrol.c	2007-11-26 16:39:00.000000000 +0900
@@ -135,6 +135,16 @@
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
 
+static inline int page_cgroup_nid(struct page_cgroup *pc)
+{
+	return page_to_nid(pc->page);
+}
+
+static inline enum zone_type page_cgroup_zid(struct page_cgroup *pc)
+{
+	return page_zonenum(pc->page);
+}
+
 enum {
 	MEM_CGROUP_TYPE_UNSPEC = 0,
 	MEM_CGROUP_TYPE_MAPPED,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
