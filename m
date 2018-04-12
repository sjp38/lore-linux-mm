Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id AEC9B6B0007
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 07:52:23 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 91-v6so3618056pla.18
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 04:52:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f11-v6si3283661plm.19.2018.04.12.04.52.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 04:52:22 -0700 (PDT)
Date: Thu, 12 Apr 2018 13:52:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
Message-ID: <20180412115217.GC23400@dhcp22.suse.cz>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On Thu 12-04-18 08:52:52, Vlastimil Babka wrote:
> On 04/11/2018 03:56 PM, Roman Gushchin wrote:
> > On Wed, Apr 11, 2018 at 03:16:08PM +0200, Vlastimil Babka wrote:
[...]
> >> With that in mind, can we at least for now put the (manually maintained)
> >> byte counter in a variable that's not directly exposed via /proc/vmstat,
> >> and then when printing nr_slab_reclaimable, simply add the value
> >> (divided by PAGE_SIZE), and when printing nr_slab_unreclaimable,
> >> subtract the same value. This way we would be simply making the existing
> >> counters more precise, in line with their semantics.
> > 
> > Idk, I don't like the idea of adding a counter outside of the vm counters
> > infrastructure, and I definitely wouldn't touch the exposed
> > nr_slab_reclaimable and nr_slab_unreclaimable fields.

Why?

> We would be just making the reported values more precise wrt reality.

I was suggesting something similar in an earlier discussion. I am not
really happy about the new exposed counter either. It is just arbitrary
by name yet very specific for this particular usecase.

What is a poor user supposed to do with the new counter? Can this be
used for any calculations?
-- 
Michal Hocko
SUSE Lab
