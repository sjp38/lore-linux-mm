Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EB68B6B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 01:25:44 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T5Pgnc029251
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 29 Jul 2010 14:25:42 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 20C6D45DE4F
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:25:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 02B7F45DE4C
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:25:42 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E111C1DB8013
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:25:41 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A38691DB8012
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:25:41 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 0/5] memcg: few nit fix and cleanups
Message-Id: <20100729140700.4AA2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 29 Jul 2010 14:25:40 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


This fixes were a part of memcg tracepoint series. and now It was divided
from such series. All patches are trivial. 



KOSAKI Motohiro (5):
  memcg: sc.nr_to_reclaim should be initialized
  memcg: kill unnecessary initialization
  memcg: mem_cgroup_shrink_node_zone() doesn't need sc.nodemask
  memcg: remove nid and zid argument from mem_cgroup_soft_limit_reclaim()
  memcg: convert to use zone_to_nid() from bare zone->zone_pgdat->node_id

 include/linux/memcontrol.h |    6 +++---
 include/linux/swap.h       |    3 +--
 mm/memcontrol.c            |   14 ++++++--------
 mm/vmscan.c                |   15 ++++-----------
 4 files changed, 14 insertions(+), 24 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
