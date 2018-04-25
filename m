Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7276D6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 11:55:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f19so16094200pfn.6
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 08:55:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b60-v6si2497504plc.270.2018.04.25.08.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Apr 2018 08:55:42 -0700 (PDT)
Date: Wed, 25 Apr 2018 08:55:39 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
Message-ID: <20180425155539.GB8546@bombadil.infradead.org>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
 <20180412145702.GB30714@castle.DHCP.thefacebook.com>
 <CAOaiJ-=JtFWNPqdtf+5uim0-LcPE9zSDZmocAa_6K3yGpW2fCQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOaiJ-=JtFWNPqdtf+5uim0-LcPE9zSDZmocAa_6K3yGpW2fCQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vinayak menon <vinayakm.list@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On Fri, Apr 13, 2018 at 05:43:39PM +0530, vinayak menon wrote:
> One such case I have encountered is that of the ION page pool. The page pool
> registers a shrinker. When not in any memory pressure page pool can go high
> and thus cause an mmap to fail when OVERCOMMIT_GUESS is set. I can send
> a patch to account ION page pool pages in NR_INDIRECTLY_RECLAIMABLE_BYTES.

Why not just account them as NR_SLAB_RECLAIMABLE?  I know it's not slab, but
other than that mis-naming, it seems like it'll do the right thing.
