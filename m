Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB9B37LN014575
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Dec 2008 20:03:07 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8580945DE52
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:03:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EA2F45DE51
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:03:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 459D31DB8037
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:03:07 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BC3B41DB8040
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:03:06 +0900 (JST)
Date: Tue, 9 Dec 2008 20:02:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 0/6] cgroup id and mix fixes (2008/12/09)
Message-Id: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


A misc patch set for memcg/cgroup including bug fix.

This set is against mm-of-the-moment snapshot 2008-12-08-16-36

[1/6] Documentation updates (thank you for Randy)
[2/6] fixing pre-destroy() (new implementation, Paul, please comment)
[3/6] cgroup id (removed codes around release_handler)
[4/6] mem_cgroup reclaim with scanning by ID (no big change.)
[5/6] fix active_ratio bug under hierarchy. (new one. very important, I think)
[6/6] fix oom-kill handler.

[2/6] and [3/6] adds codes to kernel/cgroup.c
[4/6] is for sanity of codes, removing cgroup_lock() for scanning.
[5/6] and [6/6] is bug fixes for use_hierarchy=1 case.
If my fixes cannot go ahead, we"ll have to find alternative, anyway.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
