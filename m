Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 291926B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 10:35:49 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id o3so5128739wri.5
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:35:49 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l21si715199eda.383.2018.04.13.07.35.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 07:35:47 -0700 (PDT)
Date: Fri, 13 Apr 2018 10:37:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
Message-ID: <20180413143716.GA5378@cmpxchg.org>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
 <20180413135923.GT17484@dhcp22.suse.cz>
 <13f1f5b5-f3f8-956c-145a-4641fb996048@suse.cz>
 <20180413142821.GW17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413142821.GW17484@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Apr 13, 2018 at 04:28:21PM +0200, Michal Hocko wrote:
> On Fri 13-04-18 16:20:00, Vlastimil Babka wrote:
> > We would need kmalloc-reclaimable-X variants. It could be worth it,
> > especially if we find more similar usages. I suspect they would be more
> > useful than the existing dma-kmalloc-X :)
> 
> I am still not sure why __GFP_RECLAIMABLE cannot be made work as
> expected and account slab pages as SLAB_RECLAIMABLE

Can you outline how this would work without separate caches?
