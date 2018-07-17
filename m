Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B410F6B0008
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 04:44:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u16-v6so186290pfm.15
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 01:44:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y40-v6si375785pla.470.2018.07.17.01.44.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 01:44:11 -0700 (PDT)
Subject: Re: [PATCH v2 5/7] mm: rename and change semantics of
 nr_indirectly_reclaimable_bytes
References: <20180618091808.4419-6-vbabka@suse.cz>
 <201806201923.mC5ZpigB%fengguang.wu@intel.com>
 <38c6a6e1-c5e0-fd7d-4baf-1f0f09be5094@suse.cz>
 <20180629211201.GA14897@castle.DHCP.thefacebook.com>
 <ef2dea13-0102-c4bc-a28f-c1b2408f0753@suse.cz>
 <20180702165223.GA17295@castle.DHCP.thefacebook.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <bfdb3fb1-5d81-e17c-e456-083cca04e2cc@suse.cz>
Date: Tue, 17 Jul 2018 10:44:07 +0200
MIME-Version: 1.0
In-Reply-To: <20180702165223.GA17295@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vijayanand Jitta <vjitta@codeaurora.org>, Laura Abbott <labbott@redhat.com>, Sumit Semwal <sumit.semwal@linaro.org>

On 07/02/2018 06:52 PM, Roman Gushchin wrote:
> On Sat, Jun 30, 2018 at 12:09:27PM +0200, Vlastimil Babka wrote:
>> On 06/29/2018 11:12 PM, Roman Gushchin wrote:
>>>>
>>>> The vmstat counter NR_INDIRECTLY_RECLAIMABLE_BYTES was introduced by commit
>>>> eb59254608bc ("mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES") with the goal of
>>>> accounting objects that can be reclaimed, but cannot be allocated via a
>>>> SLAB_RECLAIM_ACCOUNT cache. This is now possible via kmalloc() with
>>>> __GFP_RECLAIMABLE flag, and the dcache external names user is converted.
>>>>
>>>> The counter is however still useful for accounting direct page allocations
>>>> (i.e. not slab) with a shrinker, such as the ION page pool. So keep it, and:
>>>
>>> Btw, it looks like I've another example of usefulness of this counter:
>>> dynamic per-cpu data.
>>
>> Hmm, but are those reclaimable? Most likely not in general? Do you have
>> examples that are?
> 
> If these per-cpu data is something like per-cpu refcounters,
> which are using to manage reclaimable objects (e.g. cgroup css objects).
> Of course, they are not always reclaimable, but in certain states.

BTW, seems you seem interested, could you provide some more formal
review as well? Others too. We don't need to cover all use cases
immediately, when the patchset is apparently stalled due to lack of
review. Thanks!

> Thanks!
> 
