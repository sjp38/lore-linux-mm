Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C30BD6B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 01:47:56 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C6lrYS016760
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 15:47:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 48FED45DE6E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:47:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 119AA45DE4D
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:47:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD8B61DB803E
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:47:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C10D1DB803B
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 15:47:49 +0900 (JST)
Date: Fri, 12 Feb 2010 15:44:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/2] memcg patches around event counting...softlimit and
 thresholds
Message-Id: <20100212154422.58bfdc4d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

These 2 patches are updates for memcg's event counter.

Memcg has 2 counters but they counts the same thing. Just usages are
different from each other. This patch tries to combine them.

Event counting is done per page but event check is done per charge.
But, now, move_task at el. does charge() in batched manner. So, it's better
to do event check per page (not per charge.)

(*) There may be an opinion that threshold check should be done at charge().
    But, at charge(), event counter is not incremented, anyway.
    Then, some another idea is appreciated to check thresholds at charges.
    In other view, checking threshold at "precharge" can cause miss-fire of 
    event notifier. So, checking threshold at commit has some sense, I think.

I wonder I should add RFC..but this patch clears my concerns since memcg-threshold
was merged. So, I didn't.

Any comment is welcome. (I'm sorry if my reply is delayed.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
