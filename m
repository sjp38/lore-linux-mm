Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0FD06B0008
	for <linux-mm@kvack.org>; Thu, 24 May 2018 11:30:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 33-v6so1691635wrb.12
        for <linux-mm@kvack.org>; Thu, 24 May 2018 08:30:26 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l18-v6si2289761eda.319.2018.05.24.08.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 24 May 2018 08:30:25 -0700 (PDT)
Date: Thu, 24 May 2018 11:32:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 0/5] kmalloc-reclaimable caches
Message-ID: <20180524153225.GA7329@cmpxchg.org>
References: <20180524110011.1940-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>

On Thu, May 24, 2018 at 01:00:06PM +0200, Vlastimil Babka wrote:
> - the vmstat/meminfo counter name is rather general and might suggest it also
>   includes reclaimable page caches, which it doesn't
>
> Suggestions welcome for all three points. For the last one, we might also keep
> the counter separate from nr_slab_reclaimable, not superset. I did a superset
> as IIRC somebody suggested that in the older threads or at LSF.

Yeah, the "reclaimable" name is too generic. How about KReclaimable?

The counter being a superset sounds good to me. We use this info for
both load balancing and manual debugging. For load balancing code it's
nice not having to worry about finding all the counters that hold
reclaimable memory depending on kernel version; it's always simply
user cache + user anon + kernel reclaimable. And for debugging, we can
always add more specific subset counters later on if we need them.
