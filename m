Date: Fri, 9 May 2008 14:56:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: make global var to be read_mostly
Message-Id: <20080509145631.408a9a67.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, lizf@cn.fujitsu.com, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

An easy cut out from memcg: performance improvement patch set.
Tested on: x86-64/linux-2.6.26-rc1-git6

Thanks,
-Kame

==
mem_cgroup_subsys and page_cgroup_cache should be read_mostly and
MEM_CGROUP_RECLAIM_RETRIES can be just a fixed number.

Changelog:
  * makes MEM_CGROUP_RECLAIM_RETRIES to be a macro

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



Index: linux-2.6.26-rc1/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc1.orig/mm/memcontrol.c
+++ linux-2.6.26-rc1/mm/memcontrol.c
@@ -35,9 +35,9 @@
 
 #include <asm/uaccess.h>
 
-struct cgroup_subsys mem_cgroup_subsys;
-static const int MEM_CGROUP_RECLAIM_RETRIES = 5;
-static struct kmem_cache *page_cgroup_cache;
+struct cgroup_subsys mem_cgroup_subsys __read_mostly;
+static struct kmem_cache *page_cgroup_cache __read_mostly;
+#define MEM_CGROUP_RECLAIM_RETRIES	5
 
 /*
  * Statistics for memory cgroup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
