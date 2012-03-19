Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 35F386B00E7
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 03:58:13 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 586AA3EE0B5
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:58:11 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DE0245DE56
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:58:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 250E545DE5A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:58:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 168761DB804E
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:58:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C06AB1DB8046
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:58:10 +0900 (JST)
Message-ID: <4F66E6A5.10804@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 16:56:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/3] page cgroup diet
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

This is just an RFC...test is not enough yet.

I know it's merge window..this post is just for sharing idea.

This patch merges pc->flags and pc->mem_cgroup into a word. Then,
memcg's overhead will be 8bytes per page(4096bytes?).

Because this patch will affect all memory cgroup developers, I'd like to
show patches before MM Summit. I think we can agree the direction to
reduce size of page_cgroup..and finally integrate into 'struct page'
(and remove cgroup_disable= boot option...)

Patch 1/3 - introduce pc_to_mem_cgroup and hide pc->mem_cgroup
Patch 2/3 - remove pc->mem_cgroup
Patch 3/3 - remove memory barriers.

I'm now wondering when this change should be merged....


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
