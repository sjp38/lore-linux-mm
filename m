Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC01A6B027C
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 13:37:37 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 199so15032858iou.0
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 10:37:37 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id y21si1382898ioi.277.2018.02.12.10.37.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 10:37:36 -0800 (PST)
Date: Mon, 12 Feb 2018 12:37:33 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC] Protect larger order pages from breaking up
In-Reply-To: <20180212173630.GB9396@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1802121236220.13366@nuc-kabylake>
References: <alpine.DEB.2.20.1802091311090.3059@nuc-kabylake> <20180212173630.GB9396@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, akpm@linux-foundation.org, Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>

On Mon, 12 Feb 2018, Matthew Wilcox wrote:

> > One can then also f.e. operate the slub allocator with
> > 64k pages. Specify "slub_max_order=3 slub_min_order=3" on
> > the kernel command line and all slab allocator allocations
> > will occur in 16K page sizes.
>
> This example also reads weird ;-)

Right, this resulted in 32K page reservations and uses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
