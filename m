Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB34m9rn020620
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 13:48:09 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DAE3C45DE56
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:48:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B396045DE54
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:48:08 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 68A831DB8043
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:48:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B62B3E08001
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:48:07 +0900 (JST)
Date: Wed, 3 Dec 2008 13:47:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  0/21] memcg updates 2008/12/03
Message-Id: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is memcg update series onto
"The mm-of-the-moment snapshot 2008-12-02-17-08"

including following patches. 18-21 are highly experimenal
(so, drop CC: to Andrew)

Bug fixes.
1. memcg-revert-gfp-mask-fix.patch 
2. memcg-check-group-leader-fix.patch
3. memsw_limit_check.patch
4. memcg-swapout-refcnt-fix.patch
5. avoid-unnecessary-reclaim.patch

Kosaki's LRU works. (thanks!)
6.  inactive_anon_is_low-move-to-vmscan.patch
7.  introduce-zone_reclaim-struct.patch
8.  make-zone-nr_pages-helper-function.patch
9.  make-get_scan_ratio-to-memcg-safe.patch
10. memcg-add-null-check-to-page_cgroup_zoneinfo.patch
11. memcg-make-inactive_anon_is_low.patch
12. memcg-make-mem_cgroup_zone_nr_pages.patch
13. memcg-make-zone_reclaim_stat.patch
14. memcg-remove-mem_cgroup_cal_reclaim.patch
15. memcg-show-reclaim-stat.patch
Cleanup
16. memcg-rename-scan-glonal-lru.patch
Bug fix 
16. memcg_prev_priority_protect.patch
New Feature
17. memcg-swappiness.patch

Experimentals. need more works. (from me)
18. fix-pre-destroy.patch
19. cgroup_id.patch
20. memcg-new-hierarchical-reclaim.patch
21. memcg-explain-details-and-test.patch

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
