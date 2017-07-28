Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEF106B0521
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:59:58 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k71so38224796wrc.15
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:59:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v39si20900706wrb.306.2017.07.28.03.59.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 03:59:57 -0700 (PDT)
Date: Fri, 28 Jul 2017 11:59:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] treewide: remove GFP_TEMPORARY allocation flag
Message-ID: <20170728105953.y4gvecyjqlxnppww@suse.de>
References: <20170728091904.14627-1-mhocko@kernel.org>
 <20170728095249.n62p5nhqbekjd5yn@suse.de>
 <20170728102743.GI2274@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170728102743.GI2274@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, Neil Brown <neilb@suse.de>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 28, 2017 at 12:27:43PM +0200, Michal Hocko wrote:
> On Fri 28-07-17 10:52:49, Mel Gorman wrote:
> > On Fri, Jul 28, 2017 at 11:19:04AM +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > GFP_TEMPORARY has been introduced by e12ba74d8ff3 ("Group short-lived
> > > and reclaimable kernel allocations") along with __GFP_RECLAIMABLE. It's
> > > primary motivation was to allow users to tell that an allocation is
> > > short lived and so the allocator can try to place such allocations close
> > > together and prevent long term fragmentation. As much as this sounds
> > > like a reasonable semantic it becomes much less clear when to use the
> > > highlevel GFP_TEMPORARY allocation flag. How long is temporary? Can
> > > the context holding that memory sleep? Can it take locks? It seems
> > > there is no good answer for those questions.
> > > 
> > > The current implementation of GFP_TEMPORARY is basically
> > > GFP_KERNEL | __GFP_RECLAIMABLE which in itself is tricky because
> > > basically none of the existing caller provide a way to reclaim the
> > > allocated memory. So this is rather misleading and hard to evaluate for
> > > any benefits.
> > > 
> > 
> > At the time of the introduction, the users were all very short-lived
> > where short was for operations such as reading a proc file that discarded
> > buffers afterwards.
> 
> Maybe we can add a special slab cache for those?
> 

It was massive overkill 10 years ago given the benefit at the time. Given
that slabs can now be merged and it would be just as easy to misuse the
slab as the current GFP_TEMPORARY, I don't think it's worthwhile.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
