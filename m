Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B0CA56B02B4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 14:18:26 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id r58so8598808qtb.0
        for <linux-mm@kvack.org>; Wed, 31 May 2017 11:18:26 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g1si17232706qtf.280.2017.05.31.11.18.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 11:18:25 -0700 (PDT)
Date: Wed, 31 May 2017 11:18:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/6] mm: memcontrol: per-lruvec stats infrastructure
Message-Id: <20170531111821.14ebeee4a4181583fe6fac46@linux-foundation.org>
In-Reply-To: <20170531171450.GA10481@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
	<20170530181724.27197-6-hannes@cmpxchg.org>
	<20170531171450.GA10481@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Tony Lindgren <tony@atomide.com>, Russell King <rmk@armlinux.org.uk>, Yury Norov <ynorov@caviumnetworks.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, 31 May 2017 13:14:50 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Andrew, the 0day tester found a crash with this when special pages get
> faulted. They're not charged to any cgroup and we'll deref NULL.
> 
> Can you include the following fix on top of this patch please? Thanks!

OK.  But this won't fix the init ordering crash which the arm folks are
seeing?

I'm wondering if we should ask Stephen to drop

mm-vmstat-move-slab-statistics-from-zone-to-node-counters.patch
mm-memcontrol-use-the-node-native-slab-memory-counters.patch
mm-memcontrol-use-generic-mod_memcg_page_state-for-kmem-pages.patch
mm-memcontrol-per-lruvec-stats-infrastructure.patch
mm-memcontrol-account-slab-stats-per-lruvec.patch

until that is sorted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
