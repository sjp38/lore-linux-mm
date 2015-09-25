Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4672E6B0256
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 08:51:10 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so19113103wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 05:51:09 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id vu2si4679968wjc.90.2015.09.25.05.51.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 25 Sep 2015 05:51:09 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 8E47AC006A
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 12:51:08 +0000 (UTC)
Date: Fri, 25 Sep 2015 13:51:06 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 05/10] mm, page_alloc: Distinguish between being unable
 to sleep, unwilling to sleep and avoiding waking kswapd
Message-ID: <20150925125106.GG3068@techsingularity.net>
References: <1442832762-7247-1-git-send-email-mgorman@techsingularity.net>
 <1442832762-7247-6-git-send-email-mgorman@techsingularity.net>
 <20150924205509.GI3009@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150924205509.GI3009@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Sep 24, 2015 at 04:55:09PM -0400, Johannes Weiner wrote:
> On Mon, Sep 21, 2015 at 11:52:37AM +0100, Mel Gorman wrote:
> > @@ -119,10 +134,10 @@ struct vm_area_struct;
> >  #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
> >  #define GFP_HIGHUSER	(GFP_USER | __GFP_HIGHMEM)
> >  #define GFP_HIGHUSER_MOVABLE	(GFP_HIGHUSER | __GFP_MOVABLE)
> > -#define GFP_IOFS	(__GFP_IO | __GFP_FS)
> > -#define GFP_TRANSHUGE	(GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
> > -			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
> > -			 __GFP_NO_KSWAPD)
> > +#define GFP_IOFS	(__GFP_IO | __GFP_FS | __GFP_KSWAPD_RECLAIM)
> 
> These are some really odd semantics to be given a name like that.
> 
> GFP_IOFS was introduced as a short-hand for testing/setting/clearing
> these two bits at the same time, not to be used for allocations. In
> fact, the only user for allocations is lustre, and it's not at all
> obious why those sites shouldn't include __GFP_WAIT as well.
> 
> Removing this definition altogether would probably be best.

Ok, I'll add a TODO to create a patch that removes GFP_IOFS entirely. It
can be tacked on to the end of the series.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
