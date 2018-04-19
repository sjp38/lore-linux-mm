Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C89076B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:19:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b16so2629133pfi.5
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 04:19:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c1-v6si3241917plo.88.2018.04.19.04.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Apr 2018 04:19:40 -0700 (PDT)
Date: Thu, 19 Apr 2018 04:19:39 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 04/14] mm: Switch s_mem and slab_cache in struct page
Message-ID: <20180419111939.GB5556@bombadil.infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-5-willy@infradead.org>
 <635be88e-c361-1773-eff7-9921de503566@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <635be88e-c361-1773-eff7-9921de503566@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On Thu, Apr 19, 2018 at 01:06:30PM +0200, Vlastimil Babka wrote:
> On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> More rationale? Such as "This will allow us to ... later in the series"?

Sure.  Probably the best rationale at this point is that it'll allow us
to move slub's counters into a union with s_mem later in the series.

> > slub now needs to set page->mapping to NULL as it frees the page, just
> > like slab does.
> 
> I wonder if they should be touching the mapping field, and rather not
> the slab_cache field, with a comment why it has to be NULLed?

I add that to the documentation at the end of the series:

 * If you allocate the page using alloc_pages(), you can use some of the
 * space in struct page for your own purposes.  The five words in the first
 * union are available, except for bit 0 of the first word which must be
 * kept clear.  Many users use this word to store a pointer to an object
 * which is guaranteed to be aligned.  If you use the same storage as
 * page->mapping, you must restore it to NULL before freeing the page.

Thanks for your review!
