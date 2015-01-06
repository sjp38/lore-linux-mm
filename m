Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8265B6B00D3
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 10:33:19 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id x3so16796416qcv.22
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 07:33:19 -0800 (PST)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id v8si549097qat.30.2015.01.06.07.33.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 07:33:18 -0800 (PST)
Date: Tue, 6 Jan 2015 09:33:15 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/6] mm/slab: allocation fastpath without disabling irq
In-Reply-To: <20150106103439.GA8669@rhlx01.hs-esslingen.de>
Message-ID: <alpine.DEB.2.11.1501060931500.31349@gentwo.org>
References: <1420421851-3281-7-git-send-email-iamjoonsoo.kim@lge.com> <20150105172139.GA11201@rhlx01.hs-esslingen.de> <20150106013122.GB17222@js1304-P5Q-DELUXE> <20150106103439.GA8669@rhlx01.hs-esslingen.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Mohr <andi@lisas.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, 6 Jan 2015, Andreas Mohr wrote:
> by merely queuing them into a simple submission queue
> which then will be delay-applied by main-context
> either once main-context enters a certain "quiet" state (e.g. context switch?),
> or once main-context needs to actively take into account

This is basically the same approach as you mentioned before and would
multiply the resources needed. I think we are close to be able to avoid
allocations from interrupt contexts. Someone would need to perform an
audit to see what is left to be done. If so then lots of allocator paths
both in the page allocator and slab allocator can be dramatically
simplified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
