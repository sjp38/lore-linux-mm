Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail2.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAUAs9wj029854
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 30 Nov 2008 19:54:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8338645DD81
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:54:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 51F3945DD7D
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:54:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36B4C1DB803F
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:54:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC7F71DB8037
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:54:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 00/09] memcg: split-lru feature for memcg
Message-Id: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 30 Nov 2008 19:54:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Recently, SplitLRU patch series dramatically improvement VM reclaim
logic.

it have following improvement.
 (1) splite lru per page type
 (2) introduce inactive/active anon balancing logic
 (3) introduce anon/file balancing logic

Unfortunately, the improvement of memcgroup reclaim is incomplete.
Currently, it only has (1), but doesn't have (2) and (3).


This patch introduce (2) and (3) improvements to memcgroup.
this implementation is straightforward porting from global reclaim.

Therefere
  - code is simple.
  - memcg reclaim become efficiency as global reclaim.
  - the logic is the same as global lru.
    then, memcg reclaim debugging become easily.


this patch series has three part

[part 1: inactive-anon vs active-anon balancing improvement]
  [01/09] inactive_anon_is_low() move to vmscan.c
  [02/09] memcg: make inactive_anon_is_low()

[part 2: anon vs file balancing improvement]
  [03/09] introduce zone_reclaim struct
  [04/09] memcg: make zone_reclaim_stat
  [05/09] make zone_nr_pages() helper function
  [06/09] make get_scan_ratio() to memcg awareness
  [07/09] memcg: remove mem_cgroup_calc_reclaim()

[part 3: add split-lru related statics field to /cgroup/memory.stat]
  [08/09] memcg: show inactive_ratio
  [09/09] memcg: show reclaim stat

patch against: mmotm 29 Nov 2008


Thanks!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
