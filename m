Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9N8wUEq001318
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 23 Oct 2008 17:58:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B13E52AC026
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 17:58:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 88B1912C048
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 17:58:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DBAB1DB803E
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 17:58:30 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2921F1DB8038
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 17:58:30 +0900 (JST)
Date: Thu, 23 Oct 2008 17:58:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/11] memcg updates / clean up, lazy lru ,mem+swap
 controller
Message-Id: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

Just for internal review. Now, it's under merge window ;)

This is mem cgroup next update (in my queue.)
I'm now testing this set and would like to post next week, one by one.
(Anyway, I'll wait until mmotm/mainline seems to be setteled.)

These are against "The mm-of-the-moment snapshot 2008-10-22-17-18"

Includes 1 clean up and 4 major changes.

  a. menuconfig cleanup
     Now, "General Setup" in menuconfig is getting longer day by day...
     add cgroup submenu for good look.

  b. try/commit/cancel protocol.
     make mem_cgroup interface to be more specific and add new interface to
     try/commit/cancel.
     Because we allocates all page_cgroup at boot, we can do better handling
     of charge/uncharge calls.

  c. change force_empty's behavior from forgetting all to move to parent.
     Now, force_empty does "forget all". This is not good. 
     Change this behavior to
        - move account to the parent.
        - if the parent hits limit, free pages.
     and this remove memory.force_empty interface....a debug only brutal file.
     (This file can be a hole....)
  d. lazy lru handling.
     do add/remove to memcg's LRU in lazy way as pagevec does.

  e. Mem+Swap controller.
     account swap and limit by mem+swap. this feature is implemented as a
     extension to memcg. (mem_counter is removed.)

In my view,
   a. is ok. (patch 1,2)
   b,c,d have been tested for 2-3 weeks unchaged.. (patch 3-7)
   e. is very new and will be in my queue for more weeks. (patch8-11)


Patches.
 [1/11] fix menu's comment about page_cgroup overhead.
 [2/11] make cgroup's manuconfig as sub menu
 [3/11] introduce charge/commit/cancel
 [4/11] clean up page migration (again!)
 [5/11] fix force_empty to move account to parent
 [6/11] lazy memcg lru removal
 [7/11] lazy memcg lru add
 [8/11] make shmem's accounting clealer before mem+swap controller
 [9/11] mem+swap controller kconfig.
 [10/11] swap_cgroup for recording swap information
 [11/11] mem+swap controller core

Thank you for all your patient helps.

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
