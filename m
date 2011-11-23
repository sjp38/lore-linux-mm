Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6676B0074
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 01:41:20 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so1271018vbb.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 22:41:18 -0800 (PST)
Date: Wed, 23 Nov 2011 15:41:11 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: add task name to warn_scan_unevictable() messages
Message-ID: <20111123064111.GB25067@barrios-laptop.redhat.com>
References: <1322027721-23677-1-git-send-email-kosaki.motohiro@jp.fujitsu.com>
 <20111123062405.GA25067@barrios-laptop.redhat.com>
 <alpine.DEB.2.00.1111222230270.21009@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111222230270.21009@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 22, 2011 at 10:32:45PM -0800, David Rientjes wrote:
> On Wed, 23 Nov 2011, Minchan Kim wrote:
> 
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index a1893c0..29d163e 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -3448,9 +3448,10 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
> > >  static void warn_scan_unevictable_pages(void)
> > >  {
> > >  	printk_once(KERN_WARNING
> > > -		    "The scan_unevictable_pages sysctl/node-interface has been "
> > > +		    "%s: The scan_unevictable_pages sysctl/node-interface has been "
> > >  		    "disabled for lack of a legitimate use case.  If you have "
> > > -		    "one, please send an email to linux-mm@kvack.org.\n");
> > > +		    "one, please send an email to linux-mm@kvack.org.\n",
> > > +		    current->comm);
> > >  }
> > 
> > Just nitpick:
> > How about using WARN_ONCE instead of custom warning?
> > It can show more exact call path as well as comm.
> > I guess it's more noticible to users.
> > Anyway, either is okay to me.
> > 
> 
> When I used WARN_ONCE() to notify users that /proc/pid/oom_adj was 
> deprecated, people complained that it triggered userspace log parsers 
> thinking that there's a serious problem and it adds a taint flag so it got 
> reverted.  I'd recommend keeping it printk_once().

printk_once is better in case of not serious WARNING
once I listen your opinion.

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
