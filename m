Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A52A6B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 03:45:58 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id an2so4042139wjc.3
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 00:45:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si5057923wmu.42.2017.01.14.00.45.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 14 Jan 2017 00:45:56 -0800 (PST)
Date: Sat, 14 Jan 2017 09:45:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/6] mm: support __GFP_REPEAT in kvmalloc_node for >=64kB
Message-ID: <20170114084552.GA9962@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-3-mhocko@kernel.org>
 <b4b9bb2c-86e2-a5ca-b072-593613924929@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b4b9bb2c-86e2-a5ca-b072-593613924929@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, "Michael S. Tsirkin" <mst@redhat.com>

On Sat 14-01-17 11:42:09, Tetsuo Handa wrote:
> On 2017/01/13 0:37, Michal Hocko wrote:
[...]
> > diff --git a/mm/util.c b/mm/util.c
> > index 7e0c240b5760..9306244b9f41 100644
> > --- a/mm/util.c
> > +++ b/mm/util.c
> > @@ -333,7 +333,8 @@ EXPORT_SYMBOL(vm_mmap);
> >   * Uses kmalloc to get the memory but if the allocation fails then falls back
> >   * to the vmalloc allocator. Use kvfree for freeing the memory.
> >   *
> > - * Reclaim modifiers - __GFP_NORETRY, __GFP_REPEAT and __GFP_NOFAIL are not supported
> > + * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. __GFP_REPEAT
> > + * is supported only for large (>64kB) allocations
> 
> Isn't this ">32kB" (i.e. __GFP_REPEAT is supported for 64kB allocation) ?

True, I will update the patch to use >32kB

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
