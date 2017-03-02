Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CCC546B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:00:58 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id f84so76128150ioj.6
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:00:58 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id y204si6273664iof.62.2017.03.02.09.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 09:00:56 -0800 (PST)
Date: Thu, 2 Mar 2017 11:00:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM TOPIC] Movable memory and reliable higher order
 allocations
In-Reply-To: <20170228231733.GI16328@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1703021100320.31249@east.gentwo.org>
References: <alpine.DEB.2.20.1702281526170.31946@east.gentwo.org> <20170228231733.GI16328@bombadil.infradead.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Jesper Dangaard Brouer <brouer@redhat.com>, riel@redhat.com, Mel Gorman <mel@csn.ul.ie>

On Tue, 28 Feb 2017, Matthew Wilcox wrote:

> The radix tree is not movable given its current API.  In order to move
> a node, we need to be able to lock the tree to prevent simultaneous
> modification by another CPU.  But the radix tree API makes callers
> responsible for their own locking -- we don't even know if it's locked
> by a mutex or a spinlock, much less which lock protects this tree.
>
> This was one of my motivations for the xarray.  The xarray handles its own
> locking, so we can always lock out other CPUs from modifying the array.
> We still have to take care of RCU walkers, but that's straightforward
> to handle.  I have a prototype patch for the radix tree (ignoring the
> locking problem), so I can port that over to the xarray and post that
> for comment tomorrow.

Great. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
