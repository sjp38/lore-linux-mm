From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/12] memcg updates v5
Date: Thu, 25 Sep 2008 15:11:24 +0900
Message-ID: <20080925151124.25898d22.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754089AbYIYGFD@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Hansen <haveblue@us.ibm.com>, ryov@valinux.co.jp
List-Id: linux-mm.kvack.org

Hi, I updated the stack and reflected comments.
Against the latest mmotm. (rc7-mm1)

Major changes from previous one is 
  - page_cgroup allocation/lookup manner is changed.
    all FLATMEM/DISCONTIGMEM/SPARSEMEM and MEMORY_HOTPLUG is supported.
  - force_empty is totally rewritten. and a problem that "force_empty takes long time"
    in previous version is fixed (I think...)
  - reordered patches.
     - first half are easy ones.
     - second half are big ones.

I'm still testing with full debug option. No problem found yet.
(I'm afraid of race condition which have not been caught yet.)

[1/12]  avoid accounting special mappings not on LRU. (fix)
[2/12]  move charege() call to swapped-in page under lock_page() (clean up)
[3/12]  make root cgroup to be unlimited. (change semantics.)
[4/12]  make page->mapping NULL before calling uncharge (clean up)
[5/12]  make page->flags to use atomic ops. (changes in infrastructure)
[6/12]  optimize stat. (clean up)
[7/12]  add support function for moving account. (new function)
[8/12]  rewrite force_empty to use move_account. (change semantics.)
[9/12]  allocate all page_cgroup at boot. (changes in infrastructure)
[10/12] free page_cgroup from LRU in lazy way (optimize)
[11/12] add page_cgroup to LRU in lazy way (optimize)
[12/12] fix race at charging swap  (fix by new logic.)

*Any* comment is welcome.

Thanks,
-Kame
