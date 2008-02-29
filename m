Date: Fri, 29 Feb 2008 17:30:51 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: trivial clean up to zlc_setup
In-Reply-To: <20080229000544.5cf2667e.akpm@linux-foundation.org>
References: <20080229151057.66ED.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080229000544.5cf2667e.akpm@linux-foundation.org>
Message-Id: <20080229171136.66F6.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > -       if (jiffies - zlc->last_full_zap > 1 * HZ) {
> > +       if (time_after(jiffies, zlc->last_full_zap + HZ)) {
> >                 bitmap_zero(zlc->fullzones, MAX_ZONES_PER_ZONELIST);
> >                 zlc->last_full_zap = jiffies;
> >         }
> 
> That's a mainline bug.  Also present in 2.6.24, maybe earlier.
> But it's a minor one - we'll fix it up one second later (yes?)

I think so, may be.

Thanks.

-kosaki


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
