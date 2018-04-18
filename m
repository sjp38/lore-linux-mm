Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8C5A6B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 09:39:49 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id o8-v6so1798000wra.12
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 06:39:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t55si1270830edb.424.2018.04.18.06.39.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Apr 2018 06:39:48 -0700 (PDT)
Date: Wed, 18 Apr 2018 15:39:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm:memcg: add __GFP_NOWARN in
 __memcg_schedule_kmem_cache_create
Message-ID: <20180418133947.GE17484@dhcp22.suse.cz>
References: <20180418022912.248417-1-minchan@kernel.org>
 <20180418133139.GB27475@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418133139.GB27475@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Wed 18-04-18 06:31:39, Matthew Wilcox wrote:
> On Wed, Apr 18, 2018 at 11:29:12AM +0900, Minchan Kim wrote:
> > If there are heavy memory pressure, page allocation with __GFP_NOWAIT
> > fails easily although it's order-0 request.
> > I got below warning 9 times for normal boot.
> > 
> > Let's not make user scared.
> 
> Actually, can you explain why it's OK if this fails?  As I understand this
> code, we'll fail to create a kmalloc cache for this memcg.  What problems
> does that cause?

See http://lkml.kernel.org/r/20180418072002.GN17484@dhcp22.suse.cz

-- 
Michal Hocko
SUSE Labs
