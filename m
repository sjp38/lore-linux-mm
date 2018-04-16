Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFA9D6B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 08:27:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y10so8094317wrg.9
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 05:27:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z8si2526022edi.347.2018.04.16.05.27.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 05:27:49 -0700 (PDT)
Date: Mon, 16 Apr 2018 14:27:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180416122747.GM17484@dhcp22.suse.cz>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
 <20180413135923.GT17484@dhcp22.suse.cz>
 <13f1f5b5-f3f8-956c-145a-4641fb996048@suse.cz>
 <20180413142821.GW17484@dhcp22.suse.cz>
 <20180413143716.GA5378@cmpxchg.org>
 <20180416114144.GK17484@dhcp22.suse.cz>
 <1475594b-c1ad-9625-7aeb-ad8ad385b793@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1475594b-c1ad-9625-7aeb-ad8ad385b793@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon 16-04-18 14:06:21, Vlastimil Babka wrote:
> On 04/16/2018 01:41 PM, Michal Hocko wrote:
> > On Fri 13-04-18 10:37:16, Johannes Weiner wrote:
> >> On Fri, Apr 13, 2018 at 04:28:21PM +0200, Michal Hocko wrote:
> >>> On Fri 13-04-18 16:20:00, Vlastimil Babka wrote:
> >>>> We would need kmalloc-reclaimable-X variants. It could be worth it,
> >>>> especially if we find more similar usages. I suspect they would be more
> >>>> useful than the existing dma-kmalloc-X :)
> >>>
> >>> I am still not sure why __GFP_RECLAIMABLE cannot be made work as
> >>> expected and account slab pages as SLAB_RECLAIMABLE
> >>
> >> Can you outline how this would work without separate caches?
> > 
> > I thought that the cache would only maintain two sets of slab pages
> > depending on the allocation reuquests. I am pretty sure there will be
> > other details to iron out and
> 
> For example the percpu (and other) array caches...
> 
> > maybe it will turn out that such a large
> > portion of the chache would need to duplicate the state that a
> > completely new cache would be more reasonable.
> 
> I'm afraid that's the case, yes.
> 
> > Is this worth exploring
> > at least? I mean something like this should help with the fragmentation
> > already AFAIU. Accounting would be just free on top.
> 
> Yep. It could be also CONFIG_urable so smaller systems don't need to
> deal with the memory overhead of this.
> 
> So do we put it on LSF/MM agenda?

If you volunteer to lead the discussion, then I do not have any
objections.

-- 
Michal Hocko
SUSE Labs
