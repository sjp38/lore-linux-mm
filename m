Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 09B25620084
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 01:21:53 -0400 (EDT)
Date: Thu, 8 Apr 2010 14:09:22 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH v3 -mmotm 0/2] memcg: move charge of file cache/shmem
Message-Id: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

I updated patches for supporting move charge of file pages.

I changed the meaning of bit 1 and 2 of move_charge_at_immigrate: file pages
including tmpfs can be moved by setting bit 1 of move_charge_at_immigrate
regardless of the mapcount, and I don't use bit 2 anymore.
And I added a clean up patch based on KAMEZAWA-san's one.

  [1/2] memcg: clean up move charge
  [2/2] memcg: move charge of file pages

ChangeLog:
- v2->v3
  - based on mmotm-2010-04-05-16-09.
  - added clean up for is_target_pte_for_mc().
  - changed the meaning of bit 1 and 2. charges of file pages including tmpfs can
    be moved regardless of the mapcount by setting bit 1 of move_charge_at_immigrate.
- v1->v2
  - updated documentation.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
