Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AEA376B004D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 23:06:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9G35xsN021093
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Oct 2009 12:06:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9011245DE4F
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 12:05:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6146B45DE4E
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 12:05:59 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B8D51DB803B
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 12:05:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E09E61DB803E
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 12:05:58 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list() sc->isolate_pages() return value.
In-Reply-To: <20091016022011.GA22706@localhost>
References: <20091016111041.6ffc59c9.minchan.kim@barrios-desktop> <20091016022011.GA22706@localhost>
Message-Id: <20091016120242.AF31.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Oct 2009 12:05:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Vincent Li <root@brc.ubc.ca>, Vincent Li <macli@brc.ubc.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Fri, Oct 16, 2009 at 10:10:41AM +0800, Minchan Kim wrote:
> > Hi, Vicent. 
> > First of all, Thanks for your effort. :)
>  
> That's pretty serious efforts ;)
> 
> > But as your data said, on usual case, nr_taken_zero count is much less 
> > than non_zero. so we could lost benefit in normal case due to compare
> > insturction although it's trivial. 
> > 
> > I have no objection in this patch since overhead is not so big.
> > But I am not sure what other guys think about it. 
> > 
> > How about adding unlikely following as ?
> > 
> > +
> > +       if (unlikely(nr_taken == 0))
> > +               goto done;
> 
> I would prefer to just remove it - to make the code simple :)

+1 me.

Thank you, Vincent. Your effort was pretty clear and good.
but your mesurement data didn't persuade us.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
