Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EA8F76B004F
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 07:59:04 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BCx118016249
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 21:59:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1791E45DE51
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:59:01 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E7AD845DE50
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:59:00 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CCFB51DB803F
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:59:00 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 88D5DE18004
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 21:59:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] shrink_all_memory() use sc.nr_reclaimed
In-Reply-To: <20090211214324.6a9cfb58.minchan.kim@barrios-desktop>
References: <20090211204453.C3C3.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090211214324.6a9cfb58.minchan.kim@barrios-desktop>
Message-Id: <20090211215654.C3D6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 21:58:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Hmm, I think old bale-out code is right. 
> In shrink_all_memory, As more reclaiming with pass progressing, 
> the smaller nr_to_scan is. The nr_to_scan is the number of page shrinking which
> user want. 
> The shrink_all_zones have to reclaim nr_to_scan's page by doing best effort.
> So, If you use accumulation of reclaim, it can break bale-out in shrink_all_zones.

you are right. thanks.
shrink_all_zones()'s nr_pages != shrink_all_memory()'s nr_pages.
(I don't like this misleading variable name scheme ;)


> I mean here.
> 
> '
>               NR_LRU_BASE + l)); 
>         ret += shrink_list(l, nr_to_scan, zone,
>                 sc, prio);
>         if (ret >= nr_pages)
>           return ret; 
>       }    
> '
> 
> I have to make patch again so that it will keep on old bale-out behavior. 

Sure.
thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
