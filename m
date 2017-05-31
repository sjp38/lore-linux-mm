Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 233696B02F3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 15:02:17 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id l6so1316433iti.0
        for <linux-mm@kvack.org>; Wed, 31 May 2017 12:02:17 -0700 (PDT)
Received: from muru.com (muru.com. [72.249.23.125])
        by mx.google.com with ESMTP id u17si48886364plj.231.2017.05.31.12.02.15
        for <linux-mm@kvack.org>;
        Wed, 31 May 2017 12:02:15 -0700 (PDT)
Date: Wed, 31 May 2017 12:02:10 -0700
From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 5/6] mm: memcontrol: per-lruvec stats infrastructure
Message-ID: <20170531190209.GK3730@atomide.com>
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
Cc: Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Russell King <rmk@armlinux.org.uk>, Yury Norov <ynorov@caviumnetworks.com>, Stephen Rothwell <sfr@canb.auug.org.au>

* Andrew Morton <akpm@linux-foundation.org> [170531 11:21]:
> On Wed, 31 May 2017 13:14:50 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Andrew, the 0day tester found a crash with this when special pages get
> > faulted. They're not charged to any cgroup and we'll deref NULL.
> > 
> > Can you include the following fix on top of this patch please? Thanks!
> 
> OK.  But this won't fix the init ordering crash which the arm folks are
> seeing?

That's correct, the ordering crash is a separate problem.

> I'm wondering if we should ask Stephen to drop
> 
> mm-vmstat-move-slab-statistics-from-zone-to-node-counters.patch
> mm-memcontrol-use-the-node-native-slab-memory-counters.patch
> mm-memcontrol-use-generic-mod_memcg_page_state-for-kmem-pages.patch
> mm-memcontrol-per-lruvec-stats-infrastructure.patch
> mm-memcontrol-account-slab-stats-per-lruvec.patch
> 
> until that is sorted?

Seems like a good idea.

Regards,

Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
