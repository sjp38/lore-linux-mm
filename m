Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB24IDdD024442
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 13:18:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 020D245DE66
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:18:13 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B069E45DE61
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:18:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 81C8C1DB8040
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:18:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 245DD1DB8042
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:18:12 +0900 (JST)
Date: Tue, 2 Dec 2008 13:17:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mmotm][PATCH 0/4] request for patch replacement
Message-Id: <20081202131723.806f1724.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "hugh@veritas.com" <hugh@veritas.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi, I'm sorry for asking this.

please drop memcg-fix-gfp_mask-of-callers-of-charge.patch.

It got NACK. http://marc.info/?l=linux-kernel&m=122817796729117&w=2

To drop memcg-fix-gfp_mask-of-callers-of-charge.patch, some HUNKs in following
patches should be fixed. By dropping it, all gfp mask will turn to be GFP_KERNEL.
I'll consider how to handle this, later again.

I send replacment for 4 patches follows this mail.
==
memcg-simple-migration-handling.patch
memcg-handle-swap-caches.patch
memcg-memswap-controller-core.patch
memcg-memswap-controller-core-make-resize-limit-hold-mutex.patch

Fortunately, HUNK was not so many as expected.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
