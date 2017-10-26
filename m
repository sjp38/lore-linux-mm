Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41B8A6B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 13:14:19 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u97so1987878wrc.3
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 10:14:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61si2645354edf.188.2017.10.26.10.14.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 10:14:17 -0700 (PDT)
Date: Thu, 26 Oct 2017 19:14:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: oom: dump single excessive slab cache when oom
Message-ID: <20171026171414.mwetwu43hnxavwfn@dhcp22.suse.cz>
References: <1508971740-118317-1-git-send-email-yang.s@alibaba-inc.com>
 <1508971740-118317-3-git-send-email-yang.s@alibaba-inc.com>
 <20171026145312.6svuzriij33vzgw7@dhcp22.suse.cz>
 <44577b73-2e2d-5571-4c8b-3233e3776a52@alibaba-inc.com>
 <20171026162701.re4lclnqkngczpcl@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026162701.re4lclnqkngczpcl@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 26-10-17 18:27:01, Michal Hocko wrote:
> On Fri 27-10-17 00:15:17, Yang Shi wrote:
> > 
> > 
> > On 10/26/17 7:53 AM, Michal Hocko wrote:
> > > On Thu 26-10-17 06:49:00, Yang Shi wrote:
> > > > Per the discussion with David [1], it looks more reasonable to just dump
> > > 
> > > Please try to avoid external references in the changelog as much as
> > > possible.
> > 
> > OK.
> > 
> > > 
> > > > the single excessive slab cache instead of dumping all slab caches when
> > > > oom.
> > > 
> > > You meant to say
> > > "to just dump all slab caches which excess 10% of the total memory."
> > > 
> > > While we are at it. Abusing calc_mem_size seems to be rather clumsy and
> > > tt is not nodemask aware so you the whole thing is dubious for NUMA
> > > constrained OOMs.
> > 
> > Since we just need the total memory size of the node for NUMA constrained
> > OOM, we should be able to use show_mem_node_skip() to bring in nodemask.
> 
> yes

to be more specific. This would work for the total number of pages
calculation. This is still not enough, though. You would also have to
filter slabs per numa node and this is getting more and more complicated
for a marginal improvement.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
