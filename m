Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 27FCE6B0372
	for <linux-mm@kvack.org>; Tue,  2 May 2017 01:49:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id k14so53403302pga.5
        for <linux-mm@kvack.org>; Mon, 01 May 2017 22:49:01 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id y14si16695319pfa.219.2017.05.01.22.48.59
        for <linux-mm@kvack.org>;
        Mon, 01 May 2017 22:49:00 -0700 (PDT)
Date: Tue, 2 May 2017 14:48:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm -v3] mm, swap: Sort swap entries before free
Message-ID: <20170502054858.GA27319@bbox>
References: <87y3un2vdp.fsf@yhuang-dev.intel.com>
 <20170427043545.GA1726@bbox>
 <87r30dz6am.fsf@yhuang-dev.intel.com>
 <20170428074257.GA19510@bbox>
 <871ssdvtx5.fsf@yhuang-dev.intel.com>
 <20170428090049.GA26460@bbox>
 <87h918vjlr.fsf@yhuang-dev.intel.com>
 <878tmkvemu.fsf@yhuang-dev.intel.com>
 <20170502050228.GA27176@bbox>
 <87fugng6sj.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fugng6sj.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>

Hi Huang,

On Tue, May 02, 2017 at 01:35:24PM +0800, Huang, Ying wrote:
> Hi, Minchan,
> 
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Fri, Apr 28, 2017 at 09:35:37PM +0800, Huang, Ying wrote:
> >> In fact, during the test, I found the overhead of sort() is comparable
> >> with the performance difference of adding likely()/unlikely() to the
> >> "if" in the function.
> >
> > Huang,
> >
> > This discussion is started from your optimization code:
> >
> >         if (nr_swapfiles > 1)
> >                 sort();
> >
> > I don't have such fast machine so cannot test it. However, you added
> > such optimization code in there so I guess it's *worth* to review so
> > with spending my time, I pointed out what you are missing and
> > suggested a idea to find a compromise.
> 
> Sorry for wasting your time and Thanks a lot for your review and
> suggestion!
> 
> When I started talking this with you, I found there is some measurable
> overhead of sort().  But later when I done more tests, I found the
> measurable overhead is at the same level of likely()/unlikely() compiler
> notation.  So you help me to find that, Thanks again!
> 
> > Now you are saying sort is so fast so no worth to add more logics
> > to avoid the overhead?
> > Then, please just drop that if condition part and instead, sort
> > it unconditionally.
> 
> Now, because we found the overhead of sort() is low, I suggest to put
> minimal effort to avoid it.  Like the original implementation,
> 
>          if (nr_swapfiles > 1)
>                  sort();

It might confuse someone in future and would make him/her send a patch
to fix like we discussed. If the logic is not clear and doesn't have
measureable overhead, just leave it which is more simple/clear.

> 
> Or, we can make nr_swapfiles more correct as Tim suggested (tracking
> the number of the swap devices during swap on/off).

It might be better option but it's still hard to justify the patch
because you said it's hard to measure. Such optimiztion patch should
be from numbers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
