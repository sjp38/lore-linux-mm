Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CDD386B0044
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 23:57:08 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ4v50R028997
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 26 Nov 2009 13:57:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9453945DE5E
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 13:57:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B49845DE5A
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 13:57:05 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 00DB51DB805E
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 13:57:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B40461DB805F
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 13:56:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list() sc->isolate_pages() return value.
In-Reply-To: <20091016120242.AF31.A69D9226@jp.fujitsu.com>
References: <20091016022011.GA22706@localhost> <20091016120242.AF31.A69D9226@jp.fujitsu.com>
Message-Id: <20091126135440.5A70.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 26 Nov 2009 13:56:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Vincent Li <root@brc.ubc.ca>, Vincent Li <macli@brc.ubc.ca>, Mel Gorman <mel@csn.ul.ie>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> > On Fri, Oct 16, 2009 at 10:10:41AM +0800, Minchan Kim wrote:
> > > Hi, Vicent. 
> > > First of all, Thanks for your effort. :)
> >  
> > That's pretty serious efforts ;)
> > 
> > > But as your data said, on usual case, nr_taken_zero count is much less 
> > > than non_zero. so we could lost benefit in normal case due to compare
> > > insturction although it's trivial. 
> > > 
> > > I have no objection in this patch since overhead is not so big.
> > > But I am not sure what other guys think about it. 
> > > 
> > > How about adding unlikely following as ?
> > > 
> > > +
> > > +       if (unlikely(nr_taken == 0))
> > > +               goto done;
> > 
> > I would prefer to just remove it - to make the code simple :)
> 
> +1 me.
> 
> Thank you, Vincent. Your effort was pretty clear and good.
> but your mesurement data didn't persuade us.

This patch still exist in current mmotm.

Andrew, can you please drop mm-vsmcan-check-shrink_active_list-sc-isolate_pages-return-value.patch?
Or do you have any remain reason.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
