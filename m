Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB120t76013243
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 11:00:55 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 195D645DE5C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 11:00:52 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DB8E45DD83
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 11:00:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 31AD01DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 11:00:48 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 404411DB8043
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 11:00:47 +0900 (JST)
Date: Mon, 1 Dec 2008 11:00:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 00/09] memcg: split-lru feature for memcg
Message-Id: <20081201110000.bcdfccff.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 30 Nov 2008 19:54:08 +0900 (JST)
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
> this patch series has three part
> 
> [part 1: inactive-anon vs active-anon balancing improvement]
>   [01/09] inactive_anon_is_low() move to vmscan.c
>   [02/09] memcg: make inactive_anon_is_low()
> 
> [part 2: anon vs file balancing improvement]
>   [03/09] introduce zone_reclaim struct
>   [04/09] memcg: make zone_reclaim_stat
>   [05/09] make zone_nr_pages() helper function
>   [06/09] make get_scan_ratio() to memcg awareness
>   [07/09] memcg: remove mem_cgroup_calc_reclaim()
> 
> [part 3: add split-lru related statics field to /cgroup/memory.stat]
>   [08/09] memcg: show inactive_ratio
>   [09/09] memcg: show reclaim stat
> 
> patch against: mmotm 29 Nov 2008
> 

Hi, kosaki. thank you for your work.

My request is
 . split global-lru part and memcg part explicitly.
 
There are Nishimura's patch and my patch under development.
I may have to prepare weekly-update queue again.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
