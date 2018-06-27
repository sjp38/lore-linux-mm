Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D28746B0269
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 03:54:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j11-v6so1069372edr.15
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 00:54:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g18-v6si1780179edh.52.2018.06.27.00.54.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 00:54:04 -0700 (PDT)
Date: Wed, 27 Jun 2018 09:54:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
Message-ID: <20180627075403.GG32348@dhcp22.suse.cz>
References: <20180622162841.25114-1-mhocko@kernel.org>
 <6886dee0-3ac4-ef5d-3597-073196c81d88@suse.cz>
 <20180626100416.a3ff53f5c4aac9fae954e3f6@linux-foundation.org>
 <20180627073420.GD32348@dhcp22.suse.cz>
 <e0f4426d-1b7c-e590-aae0-e8f7ae3bb948@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e0f4426d-1b7c-e590-aae0-e8f7ae3bb948@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, JianKang Chen <chenjiankang1@huawei.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Wed 27-06-18 09:50:01, Vlastimil Babka wrote:
> On 06/27/2018 09:34 AM, Michal Hocko wrote:
> > On Tue 26-06-18 10:04:16, Andrew Morton wrote:
> > 
> > And as I've argued before the code would be wrong regardless. We would
> > leak the memory or worse touch somebody's else kmap without knowing
> > that.  So we have a choice between a mem leak, data corruption k or a
> > silent fixup. I would prefer the last option. And blowing up on a BUG
> > is not much better on something that is easily fixable. I am not really
> > convinced that & ~__GFP_HIGHMEM is something to lose sleep over.
> 
> Maybe put the fixup into a "#ifdef CONFIG_HIGHMEM" block and then modern
> systems won't care? In that case it could even be if (WARN_ON_ONCE(...))
> so future cases with wrong expectations would become known.

Yes that could be done as well. Or maybe we can make __GFP_HIGHMEM 0 for
!HIGHMEM systems. Does something really rely on it being non-zero?

-- 
Michal Hocko
SUSE Labs
