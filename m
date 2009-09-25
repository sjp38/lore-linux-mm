Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C98136B005C
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:19:27 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P8JVEl022258
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 17:19:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B3F3945DE52
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:19:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 863E045DE4F
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:19:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CDE9E08003
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:19:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 297621DB803E
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:19:29 +0900 (JST)
Date: Fri, 25 Sep 2009 17:17:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/10] memcg  clean up and some fixes for softlimit
 (Sep25)
Message-Id: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


As I posted Sep/18, I'm now planning to make memcontrol.c cleaner.
I'll post this to Andrew in the next week if no objections.
(IOW, I'll post this again. So, review itself is not very urgent.)

In this version, I dropped batched-charge/uncharge set.
They includes something delicate and should not be discussed in this thread.
The patches are organized as..

Clean up/ fix softlimit charge/uncharge under hierarchy.
1. softlimit uncharge fix
2. softlimit charge fix
These 2 are not changed for 3 weeks.

Followings are new (no functional changes.)
3.  reorder layout in memcontrol.c
4.  memcg_charge_cancel.patch from Nishimura's one
5.  clean up for memcg's percpu statistics
6.  removing unsued macro
7.  rename "cont" to "cgroup"
8.  remove unused check in charge/uncharge
9.  clean up for memcg's perzone statistics
10. Add commentary.

Because my commentary is tend to be not very good, review
for 10. is helpful ;)

I think this kind of fixes should be done while -mm queue is empty.
Then, do this first.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
