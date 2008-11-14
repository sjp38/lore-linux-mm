Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAEADV4a011716
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 14 Nov 2008 19:13:31 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E1C545DD7D
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:13:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD19A45DD7A
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:13:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A7041DB803C
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:13:29 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D1781DB803B
	for <linux-mm@kvack.org>; Fri, 14 Nov 2008 19:13:26 +0900 (JST)
Date: Fri, 14 Nov 2008 19:12:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/9] memcg updates (14/Nov/2008)
Message-Id: <20081114191246.4f69ff31.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, pbadari@us.ibm.com, jblunck@suse.de, taka@valinux.co.jp, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Several patches are posted after last update (12/Nov),
it's better to catch all up as series.

All patchs are mm-of-the-moment snapshot 2008-11-13-17-22
  http://userweb.kernel.org/~akpm/mmotm/
(You may need to patch fs/dquota.c and fix kernel/auditsc.c CONFIG error)

New ones are 1,2,3 and 9. 

IMHO, patch 1-4 are ready to go. (but I want Ack from Balbir to 3/9)

Contents:

[1/9] .... fix memory online/offline with memcg.
  This patch is for "real" memory hotplug. So, people who can test this
  is limited, I think. I asked Badari to try this.
  This fix itself is logically correct I think, but there may be other bugs..

[2/9] .... reduce size of per-cpu allocation.
  This is from Jan Blunck <jblunck@suse.de> and I picked it up and rewrote.
  please test. This tries to reduce memory usage of mem_cgroup struct.

[3/9] .... add force_empty again with proper implementation.
  I removed "force_empty" by account_move patch in mmotm. But I asked not to
  do that brutal removal of interface. I'm sorry.
  This adds "force_empty", but implemntaion itself is much saner. After this,
  force_empty is no longer "debug only" interface.

[4/9] .... account swap-cache.
  Before accounting swap, we have to handle swap-cache.
  This patch have been test for a month and seems to works well. Still here
  and waiting for bug fixes moved into..

[5/9] .... mem+swap controller kconfig
  Kconfig changes and macro for mem+swap controller.

[6/9] .... swap cgroup.
  For accounting swap, we have to prepare a strage for remembering swap.

[7/9] .... mem+swap controller.
  mem+swap controller core logic. I and Nishimura have been testing this
  for a month. It's getting nicer.

[8/9] .... synchronized LRU patch
  remove mz->lru_lock and make use of zone->lru_lock. By this, we do not have to
  duplicate vmscan's global LRU behavior in memcg.
  I think I'm an only tester of this ;) but works well.

[9/9] .... mem_cgroup_disabled() patch
  Replacing if (mem_cgroup_subsys.disabled) to be if (mem_cgroup_disabled()).
  Takahashi (dm-ioband team) posted their bio-cgroup interface working with
  page_cgroup. This is cut out from his one.
  Takahashi, If you ack me, send me Signed-off-by or Acked-by. I'll queue this.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
