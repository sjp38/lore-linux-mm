Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id CCEAC6B00D7
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 11:26:25 -0500 (EST)
Received: by mail-we0-f178.google.com with SMTP id p10so9990924wes.9
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 08:26:25 -0800 (PST)
Received: from rhlx01.hs-esslingen.de (rhlx01.hs-esslingen.de. [129.143.116.10])
        by mx.google.com with ESMTPS id z5si25320973wiy.33.2015.01.06.08.26.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 08:26:24 -0800 (PST)
Date: Tue, 6 Jan 2015 17:26:24 +0100
From: Andreas Mohr <andi@lisas.de>
Subject: Re: [PATCH 6/6] mm/slab: allocation fastpath without disabling irq
Message-ID: <20150106162624.GB24898@rhlx01.hs-esslingen.de>
References: <1420421851-3281-7-git-send-email-iamjoonsoo.kim@lge.com>
 <20150105172139.GA11201@rhlx01.hs-esslingen.de>
 <20150106013122.GB17222@js1304-P5Q-DELUXE>
 <20150106103439.GA8669@rhlx01.hs-esslingen.de>
 <alpine.DEB.2.11.1501060931500.31349@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501060931500.31349@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andreas Mohr <andi@lisas.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, Jan 06, 2015 at 09:33:15AM -0600, Christoph Lameter wrote:
> On Tue, 6 Jan 2015, Andreas Mohr wrote:
> > by merely queuing them into a simple submission queue
> > which then will be delay-applied by main-context
> > either once main-context enters a certain "quiet" state (e.g. context switch?),
> > or once main-context needs to actively take into account
> 
> This is basically the same approach as you mentioned before and would
> multiply the resources needed. I think we are close to be able to avoid
> allocations from interrupt contexts. Someone would need to perform an
> audit to see what is left to be done. If so then lots of allocator paths
> both in the page allocator and slab allocator can be dramatically
> simplified.

OK, so we seem to be already well near the finishing line of single-context
operation.

In case of multi-context access, in general I'd guess
that challenges are similar to
"traditional" multi-thread-capable heap allocator implementations in userspace,
where I'm sure large amounts of research papers (some dead-tree?)
have been written about how to achieve scalable low-contention
multi-thread access arbitration to the same shared underlying memory resource
(but since in Linux circles some implementations exceed usual
accumulated research knowledge / Best Practice, such papers may or may not be
of much help ;)

Andreas Mohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
