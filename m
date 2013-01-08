Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 336C56B005A
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 00:38:59 -0500 (EST)
Date: Tue, 8 Jan 2013 14:38:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch]mm: make madvise(MADV_WILLNEED) support swap file prefetch
Message-ID: <20130108053856.GA4714@blaptop>
References: <20130107081237.GB21779@kernel.org>
 <20130107120630.82ba51ad.akpm@linux-foundation.org>
 <50eb8180.6887320a.3f90.58b0SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130108042609.GA2459@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130108042609.GA2459@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, hughd@google.com, riel@redhat.com

Hi Shaohua,

On Tue, Jan 08, 2013 at 12:26:09PM +0800, Shaohua Li wrote:
> On Tue, Jan 08, 2013 at 10:16:07AM +0800, Wanpeng Li wrote:
> > On Mon, Jan 07, 2013 at 12:06:30PM -0800, Andrew Morton wrote:
> > >On Mon, 7 Jan 2013 16:12:37 +0800
> > >Shaohua Li <shli@kernel.org> wrote:
> > >
> > >> 
> > >> Make madvise(MADV_WILLNEED) support swap file prefetch. If memory is swapout,
> > >> this syscall can do swapin prefetch. It has no impact if the memory isn't
> > >> swapout.
> > >
> > >Seems sensible.
> > 
> > Hi Andrew and Shaohua,
> > 
> > What's the performance in the scenario of serious memory pressure? Since
> > in this case pages in swap are highly fragmented and cache hit is most
> > impossible. If WILLNEED path should add a check to skip readahead in
> > this case since swapin only leads to unnecessary memory allocation. 
> 
> pages in swap are not highly fragmented if you access memory sequentially. In
> that case, the pages you accessed will be added to lru list side by side. So if
> app does swap prefetch, we can do sequential disk access and merge small
> request to big one.

How can you make sure that the range of WILLNEED was always sequentially accesssed?

> 
> Another advantage is prefetch can drive high disk iodepth.  For sequential

What does it mean 'iodepth'? I failed to grep it in google. :(

> access, this can cause big request. Even for random access, high iodepth has
> much better performance especially for SSD.

So you mean WILLNEED is always good in where both random and sequential in "SSD"?
Then, how about the "Disk"?

Wanpeng's comment makes sense to me so I guess others can have a same question
about this patch. So it would be better to write your rationale in changelog.

> 
> Thanks,
> Shaohua
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
