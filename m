Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id A50386B0032
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 12:52:38 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id n8so15456820qaq.1
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 09:52:38 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id 8si44276876qcp.5.2015.01.05.09.52.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 05 Jan 2015 09:52:37 -0800 (PST)
Date: Mon, 5 Jan 2015 11:52:35 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 6/6] mm/slab: allocation fastpath without disabling irq
In-Reply-To: <20150105172139.GA11201@rhlx01.hs-esslingen.de>
Message-ID: <alpine.DEB.2.11.1501051151200.25076@gentwo.org>
References: <20150105172139.GA11201@rhlx01.hs-esslingen.de>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Mohr <andi@lisas.de>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>

On Mon, 5 Jan 2015, Andreas Mohr wrote:

> These thoughts also mean that I'm unsure (difficult to determine)
> of whether this change is good (i.e. a clean step in the right direction),
> or whether instead the implementation could easily directly be made
> fully independent from IRQ constraints.

We have thought a couple of times about making it independent of
interrupts. We can do that if there is guarantee that no slab operations
are going to be performed from an interrupt context. That in turn will
simplify allocator design significantly.

Regarding this patchset: I think this has the character of an RFC at this
point. There are some good ideas here but this needs to mature a bit and
get lots of feedback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
