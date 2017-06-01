Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 47F0B6B039F
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 06:07:34 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p24so30111578ioi.8
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 03:07:34 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id o10si4235979pgs.306.2017.06.01.03.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Jun 2017 03:07:33 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node counters
In-Reply-To: <20170531171151.e4zh7ffzbl4w33gd@yury-thinkpad>
References: <20170530181724.27197-1-hannes@cmpxchg.org> <20170530181724.27197-3-hannes@cmpxchg.org> <20170531091256.GA5914@osiris> <20170531113900.GB5914@osiris> <20170531171151.e4zh7ffzbl4w33gd@yury-thinkpad>
Date: Thu, 01 Jun 2017 20:07:28 +1000
Message-ID: <87mv9s2f8f.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <josef@toxicpanda.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-s390@vger.kernel.org

Yury Norov <ynorov@caviumnetworks.com> writes:

> On Wed, May 31, 2017 at 01:39:00PM +0200, Heiko Carstens wrote:
>> On Wed, May 31, 2017 at 11:12:56AM +0200, Heiko Carstens wrote:
>> > On Tue, May 30, 2017 at 02:17:20PM -0400, Johannes Weiner wrote:
>> > > To re-implement slab cache vs. page cache balancing, we'll need the
>> > > slab counters at the lruvec level, which, ever since lru reclaim was
>> > > moved from the zone to the node, is the intersection of the node, not
>> > > the zone, and the memcg.
>> > > 
>> > > We could retain the per-zone counters for when the page allocator
>> > > dumps its memory information on failures, and have counters on both
>> > > levels - which on all but NUMA node 0 is usually redundant. But let's
>> > > keep it simple for now and just move them. If anybody complains we can
>> > > restore the per-zone counters.
>> > > 
>> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>> > 
>> > This patch causes an early boot crash on s390 (linux-next as of today).
>> > CONFIG_NUMA on/off doesn't make any difference. I haven't looked any
>> > further into this yet, maybe you have an idea?
>
> The same on arm64.

And powerpc.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
