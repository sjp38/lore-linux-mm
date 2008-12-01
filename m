Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB10oE7T024105
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 09:50:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 42B7445DE58
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:50:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id A3FC145DE51
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:50:12 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 82C1E1DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:50:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EF38F1DB8043
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:50:06 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 04/09] memcg: make zone_reclaim_stat
In-Reply-To: <4932BA80.3060708@redhat.com>
References: <20081130195731.8151.KOSAKI.MOTOHIRO@jp.fujitsu.com> <4932BA80.3060708@redhat.com>
Message-Id: <20081201094856.8177.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 09:50:05 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> KOSAKI Motohiro wrote:
> 
> > @@ -172,6 +173,10 @@ void activate_page(struct page *page)
> >  
> >  		reclaim_stat->recent_rotated[!!file]++;
> >  		reclaim_stat->recent_scanned[!!file]++;
> > +
> > +		memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
> > +		memcg_reclaim_stat->recent_rotated[!!file]++;
> > +		memcg_reclaim_stat->recent_scanned[!!file]++;
> 
> Also, manipulation of the zone based reclaim_stats happens
> under the lru lock.
> 
> What protects the memcg reclaim stat?

memcg zone and memcg zone_reclaim_stat also use zone->lru_lock.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
