Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B24166B03BC
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 10:30:35 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v52so5806193wrb.14
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 07:30:35 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id 31si9340642wre.175.2017.04.20.07.30.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 07:30:34 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id B93601C162F
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 15:30:33 +0100 (IST)
Date: Thu, 20 Apr 2017 15:30:33 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Heads-up: two regressions in v4.11-rc series
Message-ID: <20170420143033.3nzi6nruqd5s3n7f@techsingularity.net>
References: <20170420110042.73d01e0f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170420110042.73d01e0f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, peterz@infradead.org

On Thu, Apr 20, 2017 at 11:00:42AM +0200, Jesper Dangaard Brouer wrote:
> Hi Linus,
> 
> Just wanted to give a heads-up on two regressions in 4.11-rc series.
> 
> (1) page allocator optimization revert
> 
> Mel Gorman and I have been playing with optimizing the page allocator,
> but Tariq spotted that we caused a regression for (NIC) drivers that
> refill DMA RX rings in softirq context.
> 
> The end result was a revert, and this is waiting in AKPMs quilt queue:
>  http://ozlabs.org/~akpm/mmots/broken-out/revert-mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
> 

This was flagged to Andrew that it should go in for either 4.11 or if
there were concerns about how close to the release we are then put it in
for 4.11-stable. At worst, I can do a resubmit to -stable myself after
it gets merged in the next window if it falls between the cracks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
