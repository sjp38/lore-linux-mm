Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 32ED36B7347
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 03:06:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so9485794edq.4
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 00:06:51 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id 29-v6si77084ejk.274.2018.12.05.00.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 00:06:49 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 1BE1D1C2096
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 08:06:49 +0000 (GMT)
Date: Wed, 5 Dec 2018 08:06:47 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 5/5] mm: Stall movable allocations until kswapd
 progresses during serious external fragmentation event
Message-ID: <20181205080647.GW23260@techsingularity.net>
References: <20181123114528.28802-1-mgorman@techsingularity.net>
 <20181123114528.28802-6-mgorman@techsingularity.net>
 <e0867205-e5f1-b007-5dc7-bb4655f6e5c1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e0867205-e5f1-b007-5dc7-bb4655f6e5c1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Nov 27, 2018 at 02:20:30PM +0100, Vlastimil Babka wrote:
> > This patch has a marginal rate on fragmentation rates as it's rare for
> > the stall logic to actually trigger but the small stalls can be enough for
> > kswapd to catch up. How much that helps is variable but probably worthwhile
> > for long-term allocation success rates. It is possible to eliminate
> > fragmentation events entirely with tuning due to this patch although that
> > would require careful evaluation to determine if it's worthwhile.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> The gains here are relatively smaller and noisier than for the previous
> patches. Also I'm afraid that once antifrag loses against the ultimate
> adversary workload (see the "Caching/buffers become useless after some
> time" thread), then this might result in adding stalls to a workload
> that has no other options but to allocate movable pages from partially
> filled unmovable blocks, because that's simply the majority of
> pageblocks in the system, and the stalls can't help the situation. If
> that proves to be true, we could revert, but then there's the new
> user-visible tunable... and that all makes it harder for me to decide
> about this patch :) If only we could find out early while this is in
> linux-mm/linux-next...
> 

Andrew, would you mind dropping this patch from mmotm please? I think
the benefit is marginal relative to the potential loss. If it turns out
we ever really do need it then hopefully there will be better data
supporting it.

Thanks.

-- 
Mel Gorman
SUSE Labs
