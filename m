Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id EDB526B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 13:12:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p29so15803129pgn.3
        for <linux-mm@kvack.org>; Wed, 31 May 2017 10:12:09 -0700 (PDT)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0074.outbound.protection.outlook.com. [104.47.34.74])
        by mx.google.com with ESMTPS id j15si4257487pga.273.2017.05.31.10.12.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 31 May 2017 10:12:07 -0700 (PDT)
Date: Wed, 31 May 2017 20:11:51 +0300
From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node
 counters
Message-ID: <20170531171151.e4zh7ffzbl4w33gd@yury-thinkpad>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
 <20170530181724.27197-3-hannes@cmpxchg.org>
 <20170531091256.GA5914@osiris>
 <20170531113900.GB5914@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531113900.GB5914@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-s390@vger.kernel.org

On Wed, May 31, 2017 at 01:39:00PM +0200, Heiko Carstens wrote:
> On Wed, May 31, 2017 at 11:12:56AM +0200, Heiko Carstens wrote:
> > On Tue, May 30, 2017 at 02:17:20PM -0400, Johannes Weiner wrote:
> > > To re-implement slab cache vs. page cache balancing, we'll need the
> > > slab counters at the lruvec level, which, ever since lru reclaim was
> > > moved from the zone to the node, is the intersection of the node, not
> > > the zone, and the memcg.
> > > 
> > > We could retain the per-zone counters for when the page allocator
> > > dumps its memory information on failures, and have counters on both
> > > levels - which on all but NUMA node 0 is usually redundant. But let's
> > > keep it simple for now and just move them. If anybody complains we can
> > > restore the per-zone counters.
> > > 
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > This patch causes an early boot crash on s390 (linux-next as of today).
> > CONFIG_NUMA on/off doesn't make any difference. I haven't looked any
> > further into this yet, maybe you have an idea?

The same on arm64.

Yury

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
