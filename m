Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EF9FF6B0055
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 08:03:14 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1BD3B2Z018547
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 11 Feb 2009 22:03:12 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7356945DE54
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 22:03:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FAA845DE50
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 22:03:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EE19B1DB803B
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 22:03:10 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A199F1DB803C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 22:03:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] shrink_all_memory() use sc.nr_reclaimed
In-Reply-To: <20090211215654.C3D6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090211214324.6a9cfb58.minchan.kim@barrios-desktop> <20090211215654.C3D6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20090211220044.C3D9.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 11 Feb 2009 22:03:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, William Lee Irwin III <wli@movementarian.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > I mean here.
> > 
> > '
> >               NR_LRU_BASE + l)); 
> >         ret += shrink_list(l, nr_to_scan, zone,
> >                 sc, prio);
> >         if (ret >= nr_pages)
> >           return ret; 
> >       }    
> > '
> > 
> > I have to make patch again so that it will keep on old bale-out behavior. 
> 
> Sure.
> thanks.

As I mean,

@@ -2082,15 +2082,14 @@ static unsigned long shrink_all_zones(unsigned long nr_pages, int prio,
 				nr_to_scan = min(nr_pages,
 					zone_page_state(zone,
 							NR_LRU_BASE + l));
				nr_reclaimed += shrink_list(l, nr_to_scan, zone,
								sc, prio);
-				if (nr_reclaimed >= nr_pages) 
-				if (nr_reclaimed > sc.swap_cluster_max) 
					break;
 		}
 	}


this is keep old behavior and consist shrink_zone(), I think.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
