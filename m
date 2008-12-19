Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4ECBB6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 03:28:28 -0500 (EST)
Date: Fri, 19 Dec 2008 17:29:03 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [bug][mmtom] memcg: MEM_CGROUP_ZSTAT underflow
Message-Id: <20081219172903.7ca9b123.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hugh@veritas.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Hi.

Current(I'm testing 2008-12-16-15-50 with some patches, though) memcg have
MEM_CGROUP_ZSTAT underflow problem.

How to reproduce:
- make a directory, set mem.limit.
- run some programs exceeding mem.limit.
- make another directory, and all the tasks in old directory to new one.
- New directory's "inactive_anon" in memory.stat underflows.

>From my investigation:
- This problem seems to happen only when swapping anonymous pages. It seems
  not to happen about shmem.
- After removing memcg-fix-swap-accounting-leak-v3.patch(and of course
  memcg-fix-swap-accounting-leak-doc-fix.patch), this problem doesn't happen.

Thoughts?


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
