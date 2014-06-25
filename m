Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id EAA8C6B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 19:32:52 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id lx4so2343018iec.31
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 16:32:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id r12si8298796icg.4.2014.06.25.16.32.52
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 16:32:52 -0700 (PDT)
Date: Wed, 25 Jun 2014 16:32:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] mm: vmscan: Do not reclaim from lower zones if they
 are balanced
Message-Id: <20140625163250.354f12cd0fa5ff16e32056bf@linux-foundation.org>
In-Reply-To: <1403683129-10814-4-git-send-email-mgorman@suse.de>
References: <1403683129-10814-1-git-send-email-mgorman@suse.de>
	<1403683129-10814-4-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Jeff Moyer <jmoyer@redhat.com>, Dave Chinner <david@fromorbit.com>

On Wed, 25 Jun 2014 08:58:46 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Historically kswapd scanned from DMA->Movable in the opposite direction
> to the page allocator to avoid allocating behind kswapd direction of
> progress. The fair zone allocation policy altered this in a non-obvious
> manner.
> 
> Traditionally, the page allocator prefers to use the highest eligible zone
> until the watermark is depleted, woke kswapd and moved onto the next zone.
> kswapd scans zones in the opposite direction so the scanning lists on
> 64-bit look like this;
> 
> ...
>
> Note that this patch makes a large performance difference for lower
> numbers of threads and brings performance closer to 3.0 figures. It was
> also tested against xfs and there are similar gains although I don't have
> 3.0 figures to compare against. There are still regressions for higher
> number of threads but this is related to changes in the CFQ IO scheduler.
> 

Why did this patch make a difference to sequential read performance? 
IOW, by what means was/is reclaim interfering with sequential reads?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
