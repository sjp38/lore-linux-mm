Date: Wed, 2 Jul 2008 21:03:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][-mm] [0/7] misc memcg patch set
Message-Id: <20080702210322.518f6c43.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi, it seems vmm-related bugs in -mm is reduced to some safe level.
I restarted my patches for memcg.

This mail is just for dumping patches on my stack.
(I'll resend one by one later.)

based on 2.6.26-rc5-mm3
+ kosaki's fixes + cgroup write_string set + Hugh Dickins's fixes for shmem
(All patches are in -mm queue.)

Any comments are welcome (but 7/7 patch is not so neat...)

[1/7] swapcache handle fix for shmem.
[2/7] adjust to split-lru: remove PAGE_CGROUP_FLAG_CACHE flag. 
[3/7] adjust to split-lru: push shmem's page to active list
      (Imported from Hugh Dickins's work.)
[4/7] reduce usage at change limit. res_counter part.
[5/7] reduce usage at change limit. memcg part.
[6/7] memcg-background-job.           res_coutner part
[7/7] memcg-background-job            memcg part.

Balbir, I'd like to import your idea of soft-limit to memcg-background-job
patch set. (Maybe better than adding hooks to very generic part.)
How do you think ?

Other patches in plan (including other guy's)
- soft-limit (Balbir works.)
  I myself think memcg-background-job patches can copperative with this.

- dirty_ratio for memcg. (haven't written at all)
  Support dirty_ratio for memcg. This will improve OOM avoidance.

- swapiness for memcg (had patches..but have to rewrite.)
  Support swapiness per memcg. (of no use ?)

- swap_controller (Maybe Nishimura works on.)
  The world may change after this...cgroup without swap can appears easily.

- hierarchy (needs more discussion. maybe after OLS?)
  have some pathes, but not in hurry.

- more performance improvements (we need some trick.)
  = Can we remove lock_page_cgroup() ?
  = Can we reduce spinlocks ?

- move resource at task move (needs helps from cgroup)
  We need some magical way. It seems impossible to implement this only by memcg.

- NUMA statistics (needs helps from cgroup)
  It seems dynamic file creation feature or some rule to show array of
  statistics should be defined.

- memory guarantee (soft-mlock.)
  guard parameter against global LRU for saying "Don't reclaim from me more ;("
  Maybe HA Linux people will want this....

Do you have others ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
