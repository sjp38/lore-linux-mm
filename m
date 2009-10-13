Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 43B4A6B00A4
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 00:54:52 -0400 (EDT)
Date: Tue, 13 Oct 2009 13:49:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 0/8] memcg: recharge at task move (Oct13)
Message-Id: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi.

These are my current patches for recharge at task move.

In current memcg, charges associated with a task aren't moved to the new cgroup
at task move. These patches are for this feature, that is, for recharging to
the new cgroup and, of course, uncharging from old cgroup at task move.

I've tested these patches on 2.6.32-rc3(+ some patches) with memory pressure
and rmdir, they didn't cause any BUGs during last weekend.

Major Changes from Sep24:
- rebased on mmotm-2009-10-09-01-07 + KAMEZAWA-san's batched charge/uncharge(Oct09)
  + part of KAMEZAWA-san's cleanup/fix patches(4,5,7 of Sep25 with some fixes).
- changed the term "migrate" to "recharge".

TODO:
- update Documentation/cgroup/memory.txt
- implement madvise(2) (MADV_MEMCG_RECHARGE/NORECHARGE)

Any comments or suggestions would be welcome.


Thanks,
Dasiuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
