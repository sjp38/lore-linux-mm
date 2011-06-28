Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9579000BD
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 04:38:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2EFD63EE0BB
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:38:25 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 110EF45DE7E
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:38:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9B6245DE7C
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:38:24 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D89731DB8040
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:38:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A5D9D1DB803C
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:38:24 +0900 (JST)
Date: Tue, 28 Jun 2011 17:31:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [FIX][PATCH 0/3] memcg: 3 fixes for memory cgroup's memory reclaim
Message-Id: <20110628173122.9e5aecdf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>


This series contains 3 fixes for memcg in Linus's git tree.
All of them were posted in the last week. I cut out and refreshed
and post it here because I think all pathces has obvious benfits, I think.

All of patches are independent from each other but you may see
some dependency between 1 and 2.

1/3 .... fix memory cgroup reclaimable check.
2/3 .... fix memory cgroup numascan update by events
3/3 .... fix lock_page() trouble when using memcg.

Because 3/3 is a patch to change behavior of __do_fault(), I'd like
to get review of mm specialists.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
