Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1D416B038B
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:32:16 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u48so2893382wrc.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:32:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k69si21950475wrc.76.2017.02.27.08.32.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 08:32:15 -0800 (PST)
Date: Mon, 27 Feb 2017 17:32:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170227163212.GN26504@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
 <20170227063315.GC23612@bbox>
 <20170227161907.GC62304@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227161907.GC62304@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Mon 27-02-17 08:19:08, Shaohua Li wrote:
> On Mon, Feb 27, 2017 at 03:33:15PM +0900, Minchan Kim wrote:
[...]
> > > --- a/include/linux/rmap.h
> > > +++ b/include/linux/rmap.h
> > > @@ -298,6 +298,6 @@ static inline int page_mkclean(struct page *page)
> > >  #define SWAP_AGAIN	1
> > >  #define SWAP_FAIL	2
> > >  #define SWAP_MLOCK	3
> > > -#define SWAP_LZFREE	4
> > > +#define SWAP_DIRTY	4
> > 
> > I still don't convinced why we should introduce SWAP_DIRTY in try_to_unmap.
> > https://marc.info/?l=linux-mm&m=148797879123238&w=2
> > 
> > We have been SetPageMlocked in there but why cannot we SetPageSwapBacked
> > in there? It's not a thing to change LRU type but it's just indication
> > we found the page's status changed in late.
> 
> This one I don't have strong preference. Personally I agree with Johannes,
> handling failure in vmscan sounds better. But since the failure handling is
> just one statement, this probably doesn't make too much difference. If Johannes
> and you made an agreement, I'll follow.

FWIW I like your current SWAP_DIRTY and the later handling at the vmscan
level more.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
