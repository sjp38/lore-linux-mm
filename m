Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D1C556B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 18:51:15 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBENpCVu022982
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 08:51:12 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AED582AEA81
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 08:51:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F0281F7042
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 08:51:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 789D51DB803A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 08:51:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 309241DB803E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 08:51:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 6/8] Stop reclaim quickly when the task reclaimed enough lots pages
In-Reply-To: <4B264F77.6040603@redhat.com>
References: <20091214213103.BBC0.A69D9226@jp.fujitsu.com> <4B264F77.6040603@redhat.com>
Message-Id: <20091215084903.CDAA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 15 Dec 2009 08:51:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> On 12/14/2009 07:31 AM, KOSAKI Motohiro wrote:
> >
> >  From latency view, There isn't any reason shrink_zones() continue to
> > reclaim another zone's page if the task reclaimed enough lots pages.
> 
> IIRC there is one reason - keeping equal pageout pressure
> between zones.
> 
> However, it may be enough if just kswapd keeps evening out
> the pressure, now that we limit the number of concurrent
> direct reclaimers in the system.
> 
> Since kswapd does not use shrink_zones ...

Sure. That's exactly my point.
plus, balance_pgdat() scan only one node. then zone balancing is
meaingfull. but shrink_zones() scan all zone in all node. we don't
need inter node balancing. it's vmscan's buisiness.


> > Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
