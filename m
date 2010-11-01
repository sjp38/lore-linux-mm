Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9A77A8D0030
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 03:07:00 -0400 (EDT)
Date: Mon, 1 Nov 2010 16:06:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] mm, mem-hotplug: recalculate lowmem_reserve when memory hotplug occur
In-Reply-To: <alpine.DEB.2.00.1010271815430.32477@chino.kir.corp.google.com>
References: <20101026221017.B7DF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1010271815430.32477@chino.kir.corp.google.com>
Message-Id: <20101101030021.6077.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 26 Oct 2010, KOSAKI Motohiro wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index b48dea2..14ee899 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5002,7 +5002,7 @@ static void __init setup_per_zone_inactive_ratio(void)
> >   * 8192MB:	11584k
> >   * 16384MB:	16384k
> >   */
> > -static int __init init_per_zone_wmark_min(void)
> > +int __meminit init_per_zone_wmark_min(void)
> >  {
> >  	unsigned long lowmem_kbytes;
> >  
> 
> setup_per_zone_inactive_ratio() should be moved from __init to __meminit, 
> right?

Right. You are pointing out very old issue. I don't know why old code
worked. but we certainly need to fix it. Thank you.

I'll prepare another incremental patch because this is another issue.
Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
