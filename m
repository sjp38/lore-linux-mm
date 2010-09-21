Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 851E86B004A
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 05:36:56 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8L9aqxl001736
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Sep 2010 18:36:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AF8D45DE54
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:36:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CA2645DD6E
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:36:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 458841DB8016
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:36:52 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id DD8F21DB8012
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 18:36:51 +0900 (JST)
Date: Tue, 21 Sep 2010 18:31:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v2 0/3][-mm] memcg: memory cgroup cput hotplug support
 update
Message-Id: <20100921183127.1c4c2bc1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


I rewrote memcg-memory-cgroup-cpu-hotplug-support-update.patch completely.
And the patch is divided into 3 part.

1/3 clean up ... delete mem_cgroup_walk_tree and add for_each_mem_cgroup_tree()
2/3 usual counters.... handles usual percpu statistics.
3/3 on_move ... handles special counters works as a kind of lock.

The direction is not different from previous one but implementation is re-designed.
I think all review comments are reflected...any comments are welcome.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
