Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 11CA96B002A
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:25:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id c11-v6so2966917pll.13
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:25:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u126si2281454pgb.628.2018.04.10.13.25.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 13:25:49 -0700 (PDT)
Date: Tue, 10 Apr 2018 13:25:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/25] slab: fixup calculate_alignment() argument type
Message-ID: <20180410202546.GC21336@bombadil.infradead.org>
References: <20180305200730.15812-1-adobriyan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org


Hi Alexey,

I came across this:

        for (order = max(min_order, (unsigned int)get_order(min_objects * size + reserved));

Do you want to work on making get_order() return an unsigned int?

Also, I think get_order(0) should probably be 0, but you might develop
a different feeling for it as you work your way around the kernel looking
at how it's used.
