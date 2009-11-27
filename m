Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 822096B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 01:29:14 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAR6TBMb010648
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 27 Nov 2009 15:29:12 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D71645DE55
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 15:29:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FF5245DE51
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 15:29:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5484C1DB8043
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 15:29:11 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id F2FF21DB8038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 15:29:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
In-Reply-To: <20091127143307.A7E1.A69D9226@jp.fujitsu.com>
References: <20091126141738.GE13095@csn.ul.ie> <20091127143307.A7E1.A69D9226@jp.fujitsu.com>
Message-Id: <20091127152824.A7EA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 27 Nov 2009 15:29:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Corrado Zoccolo <czoccolo@gmail.com>, Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Instead, PF_MEMALLOC is good idea?

This patch was obviously wrong. please forget it. i'm sorry.

> 
> 
> Subject: [PATCH] cfq: Do not limit the async queue depth while memory reclaim
> 
> Not-Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> (I haven't test this)
> ---
>  block/cfq-iosched.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
> index aa1e953..9546f64 100644
> --- a/block/cfq-iosched.c
> +++ b/block/cfq-iosched.c
> @@ -1308,7 +1308,8 @@ static bool cfq_may_dispatch(struct cfq_data *cfqd, struct cfq_queue *cfqq)
>  	 * We also ramp up the dispatch depth gradually for async IO,
>  	 * based on the last sync IO we serviced
>  	 */
> -	if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency) {
> +	if (!cfq_cfqq_sync(cfqq) && cfqd->cfq_latency &&
> +	    !(current->flags & PF_MEMALLOC)) {
>  		unsigned long last_sync = jiffies - cfqd->last_end_sync_rq;
>  		unsigned int depth;
>  
> -- 
> 1.6.5.2
> 
> 
> 
> 
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
