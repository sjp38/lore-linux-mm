Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id EC6086B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 01:49:34 -0400 (EDT)
Date: Thu, 24 Sep 2009 14:42:14 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 0/8] memcg: migrate charge at task move (24/Sep)
Message-Id: <20090924144214.508469d1.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
	<20090917160103.1bcdddee.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

I send out latest version just to share current code.

They seem to work fine in my test.
But I'm not in hurry for now, please see them when you have time.

Major differences from the previous version:

- changed "migrate_charge" flag from "int" to "bool".
- In can_attach(), parse the page table of the task and count only the number
  of target ptes and call try_charge() repeatedly. No isolation at this phase.
- In attach(), parse the page table of the task again, and isolate the target
  page and call move_account() one by one.
- do no swap-in in moving swap account.
- add support for shmem/tmpfs's swap.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
