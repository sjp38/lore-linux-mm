Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB24QKkM020464
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Dec 2008 13:26:20 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C47145DD6F
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:26:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0ADC145DD6E
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:26:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DFED51DB803A
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:26:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 922101DB803E
	for <linux-mm@kvack.org>; Tue,  2 Dec 2008 13:26:16 +0900 (JST)
Date: Tue, 2 Dec 2008 13:25:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 00/11] memcg: split-lru feature for memcg take2
Message-Id: <20081202132526.b588a1f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081201205810.1CCA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon,  1 Dec 2008 21:10:59 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Recently, SplitLRU patch series dramatically improvement VM reclaim
> logic.
> 
> it have following improvement.
>  (1) splite lru per page type
>  (2) introduce inactive/active anon balancing logic
>  (3) introduce anon/file balancing logic
> 
> Unfortunately, the improvement of memcgroup reclaim is incomplete.
> Currently, it only has (1), but doesn't have (2) and (3).
> 
> 
> This patch introduce (2) and (3) improvements to memcgroup.
> this implementation is straightforward porting from global reclaim.
> 
> Therefere
>   - code is simple.
>   - memcg reclaim become efficiency as global reclaim.
>   - the logic is the same as global lru.
>     then, memcg reclaim debugging become easily.
> 
> 
> this patch series has five part.
> 
> [part 1: global lru clean up]
>   [PATCH 01/11] inactive_anon_is_low() move to vmscan.c
>   [PATCH 02/11] introduce zone_reclaim struct
>   [PATCH 03/11] make zone_nr_pages() helper function
>   [PATCH 04/11] make get_scan_ratio() to memcg safe
> 
> [part 2: memcg: trivial fix]
>   [PATCH 05/11] memcg: add null check to page_cgroup_zoneinfo()
> 
> [part 3: memcg: inactive-anon vs active-anon balancing improvement]
>   [PATCH 06/11] memcg: make inactive_anon_is_low()
> 
> [part 4: anon vs file balancing improvement]
>   [PATCH 07/11] memcg: make mem_cgroup_zone_nr_pages()
>   [PATCH 08/11] memcg: make zone_reclaim_stat
>   [PATCH 09/11] memcg: remove mem_cgroup_calc_reclaim()
> 
> [part 5: add split-lru related statics field to /cgroup/memory.stat]
>   [PATCH 10/11] memcg: show inactive_ratio
>   [PATCH 11/11] memcg: show reclaim_stat
> 
> 
> patch against: mmotm 29 Nov 2008
> 
> Andrew, could you please pick 01-04 up to -mm?
> 01-04 don't have any behavior change.
> kamezawwa-san queue 05-11 to his memcg queueue awhile.
> 

Thanks, I'll try weekly update queue for memcg. 
(includes 01-04 if necessary)

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
