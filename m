Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 868A26B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 05:10:11 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6BE0B3EE0B3
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:10:09 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E0C245DE4F
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:10:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 33AC745DE50
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:10:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 22757EF8002
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:10:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CDE5E1DB803F
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 19:10:08 +0900 (JST)
Date: Fri, 14 Jan 2011 19:04:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/4] [BUGFIX] thp vs memcg fix.
Message-Id: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, hannes@cmpxchg.org, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Now, memcg is broken when used with THP in -mm. I thought I had more time but it's
now merged....so, I made a quick fix. I'm sorry for my laziness.

All patches are onto mmotm-Jan07. 

The issues are mainly on statistics accounting.
 - the number of anon pages in memcg.
 - the number of pages on LRU.
 - rmdir() will leak some accounts. etc.

Please see each patches for details. 

I don't have enough test time before positing, so please take this as quick
trial and give me strict review. And if you find another issues, please
notify me.

Testeres shoulld make CONFIG_TRANSPARENT_HUGEPAGE=y and
use 'always'. giving memory pressure, create/remove memory cgroup,
move tasks without account move. And see memory.stat file.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
