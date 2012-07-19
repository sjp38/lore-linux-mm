Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id B78ED6B004D
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 19:50:56 -0400 (EDT)
Date: Fri, 20 Jul 2012 08:50:57 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: +
 memory-hotplug-fix-kswapd-looping-forever-problem-fix-fix.patch added to -mm
 tree
Message-ID: <20120719235057.GA21012@bbox>
References: <20120717233115.A8E411E005C@wpzn4.hot.corp.google.com>
 <20120718012200.GA27770@bbox>
 <20120718143810.b15564b3.akpm@linux-foundation.org>
 <20120719001002.GA6579@bbox>
 <20120719002102.GN24336@google.com>
 <20120719004845.GA7346@bbox>
 <20120719165750.GP24336@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120719165750.GP24336@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ralf Baechle <ralf@linux-mips.org>, aaditya.kumar.30@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Yinghai Lu <yinghai@kernel.org>

On Thu, Jul 19, 2012 at 09:57:50AM -0700, Tejun Heo wrote:
> Hello,
> 
> On Thu, Jul 19, 2012 at 09:48:45AM +0900, Minchan Kim wrote:
> > > Maybe trigger warning if some fields which have to be zero aren't?
> > 
> > It's not good because this causes adding new WARNING in that part
> > whenever we add new field in pgdat. It nullify this patch's goal.
> 
> Maybe just do that on some fields?  The goal is catching unlikely case
> where archs leave the struct with garbage data.  I don't think full
> coverage is an absolute requirement.  Or reorganize the fields such

IIUC your previous reply, archs can use any fields during boot.
If so, we need full coverage for catching it.

> that fields unused by boot code is collected at the top so that it can
> be memset after certain offset?

If the fields touched by boot are limited, it's good idea.
Let me ask a question.
What fields are used by boot code before calling free_area_init_node
(excpet struct bootmem_data *bdata)?

> 
> But, really, given how the structure is used, I think we're better off
> just making sure all archs clear them and maybe have a sanity check or
> two just in case.  It's not like breakage on that front is gonna be
> subtle.

Of course, it seems all archs seems to zero-out already as I mentioned
(Not sure, MIPS) but Andrew doesn't want it. Andrew?

> 
> Thanks.
> 
> -- 
> tejun
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
