Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB10mvHK015502
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 1 Dec 2008 09:48:57 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E33045DE55
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:48:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AF8645DE4F
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:48:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26B061DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:48:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C2CA91DB803F
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 09:48:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 04/09] memcg: make zone_reclaim_stat
In-Reply-To: <4932BA13.7000409@redhat.com>
References: <20081130195731.8151.KOSAKI.MOTOHIRO@jp.fujitsu.com> <4932BA13.7000409@redhat.com>
Message-Id: <20081201094808.8174.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  1 Dec 2008 09:48:55 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > +struct zone_reclaim_stat*
> > +mem_cgroup_get_reclaim_stat_by_page(struct page *page)
> > +{
> > +	return NULL;
> > +}
> 
> > +		memcg_reclaim_stat = mem_cgroup_get_reclaim_stat_by_page(page);
> > +		memcg_reclaim_stat->recent_rotated[!!file]++;
> > +		memcg_reclaim_stat->recent_scanned[!!file]++;
> 
> Won't this cause a null pointer dereference when
> not using memcg?

Ahhh, thank you.
that is definitly silly bug.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
