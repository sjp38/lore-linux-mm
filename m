Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB15xvEs011666
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 14:59:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E162D45DE4F
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 14:59:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B71AB45DE50
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 14:59:56 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 885461DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 14:59:56 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 25D55E38002
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 14:59:56 +0900 (JST)
Date: Mon, 1 Dec 2008 14:59:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/3] cgroup id and scanning without cgroup_lock
Message-Id: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This is a series of patches againse mmotm-Nov29
(passed easy test)

Now, memcg supports hierarhcy. But walking cgroup tree in intellegent way
with lock/unlock cgroup_mutex seems to have troubles rather than expected.
And, I want to reduce the memory usage of swap_cgroup, which uses array of
pointers.

This patch series provides
	- cgroup_id per cgroup object.
	- lookup struct cgroup by cgroup_id
	- scan all cgroup under tree by cgroup_id. without mutex.
	- css_tryget() function.
	- fixes semantics of notify_on_release. (I think this is valid fix.)

Many changes since v1. (But I wonder some more work may be neeeded.)

BTW, I know there are some amount of patches against memcg are posted recently.
If necessary, I'll prepare Weekly-update queue again (Wednesday) and
picks all patches to linux-mm in my queue.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
