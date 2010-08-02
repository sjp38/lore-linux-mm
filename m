Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 63497600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 06:16:11 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o72AG8JR003241
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 2 Aug 2010 19:16:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 76B9345DE4F
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:16:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5955145DE4E
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:16:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 442BA1DB8012
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:16:08 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0139B1DB8014
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 19:16:05 +0900 (JST)
Date: Mon, 2 Aug 2010 19:11:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH -mm 0/5] towards I/O aware memory cgroup v3.
Message-Id: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


This is v3. removed terrble garbages from v2 and tested.(no big changes)

Now, it's merge-window and I'll have to maintain this in my box for a while.
I'll continue to update this. Maybe we can make new progress after LinuxCon.
(And I'll be busy for a while.)

This set has 2+1 purposes.
 1. re-desgin struct page_cgroup and makes room for blocckio-cgroup ID.
 2. implement quick updating method for memcg's file stat.
 3. optionally? use spin_lock instead of bit_spinlock.

Plans after this.

 1. check influence of Mel's new writeback method.
    I think we'll see OOM easier. IIUC, memory cgroup needs a thread like kswapd
    to do background writeback or low-high watermark.
    (By this, we can control priority of background writeout thread priority
     by CFS. This is very good.)

 2. implementing dirty_ratio.
    Now, Greg Thelen is working on. One of biggest problems of previous trial was
    update cost of status. I think this patch set can reduce it.

 3. record blockio cgroup's ID.
    Ikeda posted one. IIUC, it requires some consideration on (swapin)readahead
    for assigning IDs. But it seemed to be good in general.

Importance is in this order in my mind. But all aboves can be done in parallel.

Beyond that, some guys has problem with file-cache-control. If it need to use
account migration, we have to take care of races.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
