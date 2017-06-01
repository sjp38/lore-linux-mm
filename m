Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DDFD6B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 21:44:42 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a77so6771120wma.12
        for <linux-mm@kvack.org>; Wed, 31 May 2017 18:44:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l22si17517757edj.147.2017.05.31.18.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 May 2017 18:44:40 -0700 (PDT)
Date: Wed, 31 May 2017 21:44:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/6] mm: memcontrol: per-lruvec stats infrastructure
Message-ID: <20170601014425.GA11815@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-6-hannes@cmpxchg.org>
 <20170531171450.GA10481@cmpxchg.org>
 <20170531111821.14ebeee4a4181583fe6fac46@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531111821.14ebeee4a4181583fe6fac46@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Tony Lindgren <tony@atomide.com>, Russell King <rmk@armlinux.org.uk>, Yury Norov <ynorov@caviumnetworks.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, May 31, 2017 at 11:18:21AM -0700, Andrew Morton wrote:
> On Wed, 31 May 2017 13:14:50 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Andrew, the 0day tester found a crash with this when special pages get
> > faulted. They're not charged to any cgroup and we'll deref NULL.
> > 
> > Can you include the following fix on top of this patch please? Thanks!
> 
> OK.  But this won't fix the init ordering crash which the arm folks are
> seeing?
> 
> I'm wondering if we should ask Stephen to drop
> 
> mm-vmstat-move-slab-statistics-from-zone-to-node-counters.patch
> mm-memcontrol-use-the-node-native-slab-memory-counters.patch
> mm-memcontrol-use-generic-mod_memcg_page_state-for-kmem-pages.patch
> mm-memcontrol-per-lruvec-stats-infrastructure.patch
> mm-memcontrol-account-slab-stats-per-lruvec.patch

Sorry about the wreckage.

Dropping these makes sense to me for the time being.

I'll fix up the init ordering issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
