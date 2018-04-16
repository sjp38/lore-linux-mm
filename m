Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D31E56B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 07:41:47 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d37so12675736wrd.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 04:41:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si5566894edv.100.2018.04.16.04.41.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Apr 2018 04:41:46 -0700 (PDT)
Date: Mon, 16 Apr 2018 13:41:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180416114144.GK17484@dhcp22.suse.cz>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
 <20180413135923.GT17484@dhcp22.suse.cz>
 <13f1f5b5-f3f8-956c-145a-4641fb996048@suse.cz>
 <20180413142821.GW17484@dhcp22.suse.cz>
 <20180413143716.GA5378@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413143716.GA5378@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri 13-04-18 10:37:16, Johannes Weiner wrote:
> On Fri, Apr 13, 2018 at 04:28:21PM +0200, Michal Hocko wrote:
> > On Fri 13-04-18 16:20:00, Vlastimil Babka wrote:
> > > We would need kmalloc-reclaimable-X variants. It could be worth it,
> > > especially if we find more similar usages. I suspect they would be more
> > > useful than the existing dma-kmalloc-X :)
> > 
> > I am still not sure why __GFP_RECLAIMABLE cannot be made work as
> > expected and account slab pages as SLAB_RECLAIMABLE
> 
> Can you outline how this would work without separate caches?

I thought that the cache would only maintain two sets of slab pages
depending on the allocation reuquests. I am pretty sure there will be
other details to iron out and maybe it will turn out that such a large
portion of the chache would need to duplicate the state that a
completely new cache would be more reasonable. Is this worth exploring
at least? I mean something like this should help with the fragmentation
already AFAIU. Accounting would be just free on top.

-- 
Michal Hocko
SUSE Labs
