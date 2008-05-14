Date: Wed, 14 May 2008 17:02:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH 0/6] memcg: peformance improvement at el. v3
Message-Id: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This set is for memory resource controller, reviewer and testers. 

Updated against 2.6.26-rc2 and added fixes.

This set does
 - remove refcnt from page_cgroup. By this, codes can be simplified and
   we can avoid tons of unnecessary calls just for maintain refcnt.
 - handle swap-cache, which is now ignored by memory resource controller.
 - small optimization.
 - make force_empty to drop pages. (NEW)
 
major changes : v2 -> v3
 - fixed shared memory handling.
 - added a call to request recalaim memory from specified memcg (NEW) for shmem.
 - added drop_all_pages_in_mem_cgroup before calling force_empty()
 - dropped 3 patches because it's already sent to -mm queue.

 1/6 -- make force_empty to drop pages. (NEW)
 2/6 -- remove refcnt from page_cgroup (shmem handling is fixed.)
 3/6 -- handle swap cache
 4/6 -- add an interface to reclaim memory from memcg (NEW) (for shmem)
 5/6 -- small optimzation with likely()/unlikely()
 6/6 -- remove redundant check.

If positive feedback, I'd like to send some of them agaisnt -mm queue.

This is based on
  - 2.6.26-rc2 
  - memcg-avoid-unnecessary-initialization.patch (in -mm queue)
  - memcg-make-global-var-read_mostly.patch (in -mm queue)
  - memcg-better-migration-handling.patch (in -mm queue)
tested on x86-64 box. Seems to work very well.

Any comments are welcome.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
