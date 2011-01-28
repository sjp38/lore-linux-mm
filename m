Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A99FA8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 22:28:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 34A993EE0B5
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:28:56 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 119A145DE50
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:28:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id EEC6745DE51
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:28:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E121B1DB8040
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:28:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ACE921DB803E
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 12:28:55 +0900 (JST)
Date: Fri, 28 Jan 2011 12:22:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH 0/4] Fixes for memcg with THP
Message-Id: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


On recent -mm, when I run make -j 8 under 200M limit of memcg, as
==
# mount -t cgroup none /cgroup/memory -o memory
# mkdir /cgroup/memory/A
# echo 200M > /cgroup/memory/A/memory.limit_in_bytes
# echo $$ > /cgroup/memory/A/tasks
# make -j 8 kernel
==

I see hangs with khugepaged. That's because memcg's memory reclaim
routine doesn't handle HUGE_PAGE request in proper way. And khugepaged
doesn't know about memcg.

This patch set is for fixing above hang. Patch 1-3 seems obvious and
has the same concept as patches in RHEL.

Patch 4 may need discussion. I think this version is much simpler
because I dropped almost all cosmetics. Please review.

This patch is onto mmotm-0125.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
