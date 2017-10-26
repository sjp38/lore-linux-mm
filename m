Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA8496B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 12:27:06 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 196so2092233wma.6
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:27:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r6si3835776edi.539.2017.10.26.09.27.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 09:27:05 -0700 (PDT)
Date: Thu, 26 Oct 2017 18:27:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: oom: dump single excessive slab cache when oom
Message-ID: <20171026162701.re4lclnqkngczpcl@dhcp22.suse.cz>
References: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
 <1508971740-118317-3-git-send-email-yang.s@alibaba-inc.com>
 <20171026145312.6svuzriij33vzgw7@dhcp22.suse.cz>
 <44577b73-2e2d-5571-4c8b-3233e3776a52@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <44577b73-2e2d-5571-4c8b-3233e3776a52@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 27-10-17 00:15:17, Yang Shi wrote:
> 
> 
> On 10/26/17 7:53 AM, Michal Hocko wrote:
> > On Thu 26-10-17 06:49:00, Yang Shi wrote:
> > > Per the discussion with David [1], it looks more reasonable to just dump
> > 
> > Please try to avoid external references in the changelog as much as
> > possible.
> 
> OK.
> 
> > 
> > > the single excessive slab cache instead of dumping all slab caches when
> > > oom.
> > 
> > You meant to say
> > "to just dump all slab caches which excess 10% of the total memory."
> > 
> > While we are at it. Abusing calc_mem_size seems to be rather clumsy and
> > tt is not nodemask aware so you the whole thing is dubious for NUMA
> > constrained OOMs.
> 
> Since we just need the total memory size of the node for NUMA constrained
> OOM, we should be able to use show_mem_node_skip() to bring in nodemask.

yes

> > The more I think about this the more I am convinced that this is just
> > fiddling with the code without a good reason and without much better
> > outcome.
> 
> I don't get you. Do you mean the benefit is not that much with just dumping
> excessive slab caches?

Yes, I am not sure it makes sense to touch it without further
experiences. I am not saying this is a wrong approach I would just give
it some more time to see how it behaves in the wild and then make
changes based on that experience.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
