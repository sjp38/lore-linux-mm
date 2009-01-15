Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3B6A46B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 05:22:29 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0FAMQbM030584
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 19:22:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A5C345DD72
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:22:26 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E27EE45DE53
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:22:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 93C281DB8047
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:22:25 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 222351DB804B
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:22:25 +0900 (JST)
Date: Thu, 15 Jan 2009 19:21:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] cgroup/memcg : updates related to CSS
Message-Id: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


I'm sorry that I couldn't work so much, this week.
No much updates but I think all comments I got are applied.

About memcg part, I'll wait for that all Nishimura's fixes go ahead.
If cgroup part looks good, please Ack. I added CC to Andrew Morton for that part.

changes from previous series
  - dropeed a fix to OOM KILL   (will reschedule)
  - dropped a fix to -EBUSY     (will reschedule)
  - added css_is_populated()
  - added hierarchy_stat patch

Known my homework is
  - resize_limit should return -EBUSY. (Li Zefan reported.)

Andrew, I'll CC: you [1/4] and [2/4]. But no explicit Acked-by yet to any patches.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
