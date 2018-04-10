Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 898806B0031
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 16:47:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z15so8743550wrh.10
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 13:47:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m78sor714808wma.38.2018.04.10.13.47.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 13:47:35 -0700 (PDT)
Date: Tue, 10 Apr 2018 23:47:32 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 01/25] slab: fixup calculate_alignment() argument type
Message-ID: <20180410204732.GA11918@avx2>
References: <20180305200730.15812-1-adobriyan@gmail.com>
 <20180410202546.GC21336@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410202546.GC21336@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

On Tue, Apr 10, 2018 at 01:25:46PM -0700, Matthew Wilcox wrote:
> I came across this:
> 
>         for (order = max(min_order, (unsigned int)get_order(min_objects * size + reserved));
> 
> Do you want to work on making get_order() return an unsigned int?
> 
> Also, I think get_order(0) should probably be 0, but you might develop
> a different feeling for it as you work your way around the kernel looking
> at how it's used.

IIRC total size increased when I made it return "unsigned int".

Another thing is that there should be 3 get_order's corresponding
to 32-bit, 64-bit and unsigned long versions of fls() which correspond
to REX and non-REX versions of BSR.
