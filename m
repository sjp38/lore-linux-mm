Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB34sXKs023878
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 13:54:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E26145DE55
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:54:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A80545DE5D
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:54:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 069231DB8041
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:54:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 445001DB8048
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:54:28 +0900 (JST)
Date: Wed, 3 Dec 2008 13:53:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  5/21] memcg-hierarchy-avoid-unnecessary-reclaim.patch
Message-Id: <20081203135339.159bb8ca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

If hierarchy is not used, no tree-walk is necessary.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |    2 ++
 1 file changed, 2 insertions(+)

Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -606,6 +606,8 @@ static int mem_cgroup_hierarchical_recla
 	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
 	if (mem_cgroup_check_under_limit(root_mem))
 		return 0;
+	if (!root_mem->use_hierarchy)
+		return ret;
 
 	next_mem = mem_cgroup_get_first_node(root_mem);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
