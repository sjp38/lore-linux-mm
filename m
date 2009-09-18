Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CA3FB6B00AD
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 04:50:23 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8I8oSks032695
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Sep 2009 17:50:28 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id ECA9045DE5D
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:50:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1D3245DE51
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:50:27 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F01948F8008
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:50:26 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D02031DB8046
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 17:50:23 +0900 (JST)
Date: Fri, 18 Sep 2009 17:47:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/11][mmotm] memcg: patch dump (Sep/18)
Message-Id: <20090918174757.672f1e8e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090909173903.afc86d85.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Posting just for dumping my stack, plz see if you have time.
(will repost, this set is not for any merge)

Because my office is closed until next Thursday, my RTT will be long for a while.

Patches are mainly in 3 parts.
 - soft-limit modification (1,2)
 - coalescing chages (3,4)
 - cleanups. (5-11)

In these days, I feel I have to make memcgroup.c cleaner.
Some comments are old and placement of functions are at random.

Patches are still messy but plz see applied image if you interested in.

1. fix up softlimit's uncharge path
2. fix up softlimit's charge path
3. coalescing uncharge path
4. coalescing charge path
5. memcg_charge_cancel ....from Nishimura's set. this is very nice.
6. clean up percpu statistics of memcg.
7. clean up mem_cgroup_from_xxxx functions.
8. adds commentary and remove unused macros.
9. clean up for mem_cgroup's per-zone stat
10. adds commentary for soft-limit and moves functions for per-cpu 
11. misc. commentary and function replacement...not sorted out well.

Patches in 6-11 sounds like bad-news for Nishimura-san, but I guess
no heavy hunk you'll have...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
