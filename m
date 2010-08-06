Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 37C696B02BF
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 06:17:35 -0400 (EDT)
Subject: Re: [PATCH 03/13] writeback: add comment to the dirty limits
 functions
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100805162433.105093335@intel.com>
References: <20100805161051.501816677@intel.com>
	 <20100805162433.105093335@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 06 Aug 2010 12:17:26 +0200
Message-ID: <1281089846.1947.411.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-08-06 at 00:10 +0800, Wu Fengguang wrote:

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

> +/**
> + * bdi_dirty_limit - @bdi's share of dirty throttling threshold
> + *
> + * Allocate high/low dirty limits to fast/slow devices, in order to prev=
ent
> + * - starving fast devices
> + * - piling up dirty pages (that will take long time to sync) on slow de=
vices
> + *
> + * The bdi's share of dirty limit will be adapting to its throughput and
> + * bounded by the bdi->min_ratio and/or bdi->max_ratio parameters, if se=
t.
> + */=20

Another thing solved by the introduction of per-bdi dirty limits (and
now per-bdi flushing) is the whole stacked-bdi writeout deadlock.

Although I'm not sure we want/need to mention that here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
