Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB36IUK6025400
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 15:18:30 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6554945DE50
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 15:18:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EDFE45DE52
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 15:18:30 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EDCC21DB803A
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 15:18:29 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A6CB1DB8043
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 15:18:29 +0900 (JST)
Date: Wed, 3 Dec 2008 15:17:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH  0/21] memcg updates 2008/12/03
Message-Id: <20081203151740.f5da4349.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081202215650.e7621524.akpm@linux-foundation.org>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
	<20081202215650.e7621524.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Dec 2008 21:56:50 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Wed, 3 Dec 2008 13:47:18 +0900 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > This is memcg update series onto
> > "The mm-of-the-moment snapshot 2008-12-02-17-08"
> 
> Complaints...
> 
> - All these patches had filenames in their Subject: lines.  I turned
>   these all back into sensible-sounding English titles.
> 
Sorry..

> - I think a lot of authorships got lost.  For example, the way these
>   patches were sent, you will be identified as the author of
>   inactive_anon_is_low-move-to-vmscan.patch, but I don't think you
>   were.  So please work out the correct authorship for
> 
Sure. some patch includes modification from me (no big changes)

> 	memcg-revert-gfp-mask-fix.patch
	Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> 	memcg-check-group-leader-fix.patch
	Author: Nikanth Karthikesan <knikanth@suse.de>  
	a bit modified by me.

> 	memcg-memoryswap-controller-fix-limit-check.patch
	Author: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
	a bit modified by me.

> 	memcg-swapout-refcnt-fix.patch
	Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> 	memcg-hierarchy-avoid-unnecessary-reclaim.patch
	Author: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
	a bit modified by me.

> 	inactive_anon_is_low-move-to-vmscan.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 	mm-introduce-zone_reclaim-struct.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 	mm-add-zone-nr_pages-helper-function.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
	
> 	mm-make-get_scan_ratio-safe-for-memcg.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
	
> 	memcg-add-null-check-to-page_cgroup_zoneinfo.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
	
> 	memcg-add-inactive_anon_is_low.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
	
> 	memcg-add-mem_cgroup_zone_nr_pages.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 	memcg-add-zone_reclaim_stat.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 	memcg-remove-mem_cgroup_cal_reclaim.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 	memcg-show-reclaim-stat.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
	a bit modified by me.

> 	memcg-rename-scan-global-lru.patch
	Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> 	memcg-protect-prev_priority.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 	memcg-swappiness.patch
	Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
	fixed bug by me.

> 	memcg-explain-details-and-test-document.patch
	Author: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
>   and let me know?
> 
> - Sentences start with capital letters.
> 
> - Your patches are missing the ^--- after the changelog.  This
>   creates additional work (and potential for mistakes) at the other
>   end.
will fix when I do this kind of again..

> 
> - I didn't check whether any acked-by's got lost.  They may have been...
> 

AFAIK, only Acks from people other than Kamezawa, Balbir, Nishimura to aboves
are Rik van Riel's. I think I've picked up all.


Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
