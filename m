Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id F289A6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 00:29:16 -0500 (EST)
Date: Fri, 6 Nov 2009 14:10:11 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 0/8] memcg: recharge at task move
Message-Id: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

In current memcg, charges associated with a task aren't moved to the new cgroup
at task move. These patches are for this feature, that is, for recharging to
the new cgroup and, of course, uncharging from old cgroup at task move.

Current virsion supports only recharge of non-shared(mapcount == 1) anonymous pages
and swaps of those pages. I think it's enough as a first step.

[1/8] cgroup: introduce cancel_attach()
[2/8] memcg: move memcg_tasklist mutex
[3/8] memcg: add mem_cgroup_cancel_charge()
[4/8] memcg: cleanup mem_cgroup_move_parent()
[5/8] memcg: add interface to recharge at task move
[6/8] memcg: recharge charges of anonymous page
[7/8] memcg: avoid oom during recharge at task move
[8/8] memcg: recharge charges of anonymous swap

2 is dependent on 1 and 4 is dependent on 3.
3 and 4 are just for cleanups.
5-8 are the body of this feature.

Major Changes from Oct13:
- removed "[RFC]".
- rebased on mmotm-2009-11-01-10-01.
- dropped support for file cache and shmem/tmpfs(revisit in future).
- Updated Documentation/cgroup/memory.txt.

TODO:
- add support for file cache, shmem/tmpfs, and shared(mapcount > 1) pages.
- implement madvise(2) to let users decide the target vma for recharge.

Any comments or suggestions would be welcome.


Thanks,
Dasiuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
