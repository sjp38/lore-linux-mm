Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BF1F46B006A
	for <linux-mm@kvack.org>; Sun,  9 Aug 2009 22:58:03 -0400 (EDT)
Date: Mon, 10 Aug 2009 11:23:26 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][PATCH 0/2] mm: some patches about add_to_swap_cache()
Message-Id: <20090810112326.3526b11d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

These are patches about add_to_swap_cache(), related to
the commit 355cfa73(mm: modify swap_map and add SWAP_HAS_CACHE flag).

[BUGFIX][1/2] mm: add_to_swap_cache() must not sleep
[cleanup][2/2] mm: add_to_swap_cache() does not return -EEXIST

These are based on 2.6.31-rc5, but can be applied onto mmotm.
Any comments or suggestions would be welcome.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
