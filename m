Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F07DC6B0044
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 04:35:18 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0M9ZGwc032387
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Jan 2009 18:35:16 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E217745DE50
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:35:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C6AE345DE4F
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:35:15 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id AEC8AE18001
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:35:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A1C31DB803E
	for <linux-mm@kvack.org>; Thu, 22 Jan 2009 18:35:15 +0900 (JST)
Date: Thu, 22 Jan 2009 18:34:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/7] cgroup/memcg updates 2009/01/22
Message-Id: <20090122183411.3cabdfd2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


This is an updates from previes CSS ID patch set and some updates to memcg.
But it seems people are enjoying LinuxConf.au, I'll keep this set on my box
for a while ;)

This set contains following patches 
==
[1/7] add CSS ID to cgroup.
[2/7] use CSS ID under memcg
[3/7] show more hierarchical information via memory.stat file
[4/7] fix "set limit" to return -EBUSY if it seems difficult to shrink usage.
[5/7] fix OOM-Killer under memcg's hierarchy.
[6/7] fix frequent -EBUSY at cgroup rmdir() with memory subsystem.
[7/7] support background reclaim. (for RFC)

patch 4, 7 is new.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
