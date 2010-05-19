Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1798A6B023F
	for <linux-mm@kvack.org>; Wed, 19 May 2010 17:34:54 -0400 (EDT)
Date: Wed, 19 May 2010 23:34:46 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/5] vmscan: remove all_unreclaimable scan control
Message-ID: <20100519213446.GB2868@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
 <20100430224316.056084208@cmpxchg.org>
 <20100513120536.215B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513120536.215B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 12:25:36PM +0900, KOSAKI Motohiro wrote:
> > @@ -1789,7 +1787,7 @@ static unsigned long do_try_to_free_page
> >  		sc->nr_scanned = 0;
> >  		if (!priority)
> >  			disable_swap_token();
> > -		shrink_zones(priority, zonelist, sc);
> > +		ret = shrink_zones(priority, zonelist, sc);
> 
> Please use more good name instead 'ret' ;)

Guess you are right, let me send a follow-up.

> otherwise looks good.
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thank you.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
