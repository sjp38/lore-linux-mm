Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1FBCF6B006A
	for <linux-mm@kvack.org>; Thu, 14 Jan 2010 03:32:49 -0500 (EST)
Date: Thu, 14 Jan 2010 16:32:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [resend][PATCH] mm: Restore zone->all_unreclaimable to
	independence word
Message-ID: <20100114083229.GA7860@localhost>
References: <20100114103332.D71B.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1001132229250.15428@chino.kir.corp.google.com> <20100114161311.673B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100114161311.673B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 14, 2010 at 03:14:10PM +0800, KOSAKI Motohiro wrote:
> > On Thu, 14 Jan 2010, KOSAKI Motohiro wrote:
> > 
> > > commit e815af95 (change all_unreclaimable zone member to flags) chage
> > > all_unreclaimable member to bit flag. but It have undesireble side
> > > effect.
> > > free_one_page() is one of most hot path in linux kernel and increasing
> > > atomic ops in it can reduce kernel performance a bit.
> > > 
> > > Thus, this patch revert such commit partially. at least
> > > all_unreclaimable shouldn't share memory word with other zone flags.
> > > 
> > 
> > I still think you need to quantify this; saying you don't have a large 
> > enough of a machine that will benefit from it isn't really a rationale for 
> > the lack of any data supporting your claim.  We should be basing VM 
> > changes on data, not on speculation that there's a measurable impact 
> > here.
> > 
> > Perhaps you could ask a colleague or another hacker to run a benchmark for 
> > you so that the changelog is complete?
> 
> ok, fair. although I dislike current unnecessary atomic-ops.
> I'll pending this patch until get good data.

I think it's a reasonable expectation to help large boxes.

What we can do now, is to measure if it hurts mainline SMP
boxes. If not, we are set on doing the patch :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
