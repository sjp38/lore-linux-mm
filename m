Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id DD22F6B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 12:53:26 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id r1-v6so2657367lfi.16
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 09:53:26 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id e13-v6si7113773lfi.29.2018.07.02.09.53.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 09:53:24 -0700 (PDT)
Date: Mon, 2 Jul 2018 09:52:27 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 5/7] mm: rename and change semantics of
 nr_indirectly_reclaimable_bytes
Message-ID: <20180702165223.GA17295@castle.DHCP.thefacebook.com>
References: <20180618091808.4419-6-vbabka@suse.cz>
 <201806201923.mC5ZpigB%fengguang.wu@intel.com>
 <38c6a6e1-c5e0-fd7d-4baf-1f0f09be5094@suse.cz>
 <20180629211201.GA14897@castle.DHCP.thefacebook.com>
 <ef2dea13-0102-c4bc-a28f-c1b2408f0753@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <ef2dea13-0102-c4bc-a28f-c1b2408f0753@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vijayanand Jitta <vjitta@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>

On Sat, Jun 30, 2018 at 12:09:27PM +0200, Vlastimil Babka wrote:
> On 06/29/2018 11:12 PM, Roman Gushchin wrote:
> >>
> >> The vmstat counter NR_INDIRECTLY_RECLAIMABLE_BYTES was introduced by commit
> >> eb59254608bc ("mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES") with the goal of
> >> accounting objects that can be reclaimed, but cannot be allocated via a
> >> SLAB_RECLAIM_ACCOUNT cache. This is now possible via kmalloc() with
> >> __GFP_RECLAIMABLE flag, and the dcache external names user is converted.
> >>
> >> The counter is however still useful for accounting direct page allocations
> >> (i.e. not slab) with a shrinker, such as the ION page pool. So keep it, and:
> > 
> > Btw, it looks like I've another example of usefulness of this counter:
> > dynamic per-cpu data.
> 
> Hmm, but are those reclaimable? Most likely not in general? Do you have
> examples that are?

If these per-cpu data is something like per-cpu refcounters,
which are using to manage reclaimable objects (e.g. cgroup css objects).
Of course, they are not always reclaimable, but in certain states.

Thanks!
