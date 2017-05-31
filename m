Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C40726B02F4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 18:03:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h76so28659029pfh.15
        for <linux-mm@kvack.org>; Wed, 31 May 2017 15:03:45 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id l9si17617447pgn.222.2017.05.31.15.03.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 May 2017 15:03:45 -0700 (PDT)
Date: Thu, 1 Jun 2017 08:03:40 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 5/6] mm: memcontrol: per-lruvec stats infrastructure
Message-ID: <20170601080340.3abea4e9@canb.auug.org.au>
In-Reply-To: <20170531190209.GK3730@atomide.com>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
	<20170530181724.27197-6-hannes@cmpxchg.org>
	<20170531171450.GA10481@cmpxchg.org>
	<20170531111821.14ebeee4a4181583fe6fac46@linux-foundation.org>
	<20170531190209.GK3730@atomide.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Lindgren <tony@atomide.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Russell King <rmk@armlinux.org.uk>, Yury Norov <ynorov@caviumnetworks.com>

Hi Tony, Andrew,

On Wed, 31 May 2017 12:02:10 -0700 Tony Lindgren <tony@atomide.com> wrote:
>
> * Andrew Morton <akpm@linux-foundation.org> [170531 11:21]:
> > On Wed, 31 May 2017 13:14:50 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> >   
> > > Andrew, the 0day tester found a crash with this when special pages get
> > > faulted. They're not charged to any cgroup and we'll deref NULL.
> > > 
> > > Can you include the following fix on top of this patch please? Thanks!  
> > 
> > OK.  But this won't fix the init ordering crash which the arm folks are
> > seeing?  
> 
> That's correct, the ordering crash is a separate problem.
> 
> > I'm wondering if we should ask Stephen to drop
> > 
> > mm-vmstat-move-slab-statistics-from-zone-to-node-counters.patch
> > mm-memcontrol-use-the-node-native-slab-memory-counters.patch
> > mm-memcontrol-use-generic-mod_memcg_page_state-for-kmem-pages.patch
> > mm-memcontrol-per-lruvec-stats-infrastructure.patch
> > mm-memcontrol-account-slab-stats-per-lruvec.patch
> > 
> > until that is sorted?  
> 
> Seems like a good idea.

OK, I have removed them.

-- 
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
