Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 947FB6B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 17:02:28 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id o33-v6so10332286plb.16
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 14:02:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d67si2722230pfb.232.2018.04.10.14.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 14:02:27 -0700 (PDT)
Date: Tue, 10 Apr 2018 14:02:25 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/25] slab: fixup calculate_alignment() argument type
Message-ID: <20180410210225.GE21336@bombadil.infradead.org>
References: <20180305200730.15812-1-adobriyan@gmail.com>
 <20180410202546.GC21336@bombadil.infradead.org>
 <20180410204732.GA11918@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410204732.GA11918@avx2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Tue, Apr 10, 2018 at 11:47:32PM +0300, Alexey Dobriyan wrote:
> On Tue, Apr 10, 2018 at 01:25:46PM -0700, Matthew Wilcox wrote:
> > I came across this:
> > 
> >         for (order = max(min_order, (unsigned int)get_order(min_objects * size + reserved));
> > 
> > Do you want to work on making get_order() return an unsigned int?
> > 
> > Also, I think get_order(0) should probably be 0, but you might develop
> > a different feeling for it as you work your way around the kernel looking
> > at how it's used.
> 
> IIRC total size increased when I made it return "unsigned int".

Huh, weird.  Did you go so far as to try having it return unsigned char?
We know it's not going to return anything outside the range of 0-63.
