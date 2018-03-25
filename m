Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FFBF6B0003
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 19:56:08 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c5so10099228pfn.17
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 16:56:08 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o15-v6si13230573pli.738.2018.03.25.16.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 25 Mar 2018 16:56:05 -0700 (PDT)
Date: Sun, 25 Mar 2018 16:56:03 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/4] mm: Add free()
Message-ID: <20180325235603.GA18737@bombadil.infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
 <20180322195819.24271-4-willy@infradead.org>
 <6fd1bba1-e60c-e5b3-58be-52e991cda74f@virtuozzo.com>
 <20180323151421.GC5624@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180323151421.GC5624@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Mar 23, 2018 at 08:14:21AM -0700, Matthew Wilcox wrote:
> On Fri, Mar 23, 2018 at 04:33:24PM +0300, Kirill Tkhai wrote:
> > > +	page = virt_to_head_page(ptr);
> > > +	if (likely(PageSlab(page)))
> > > +		return kmem_cache_free(page->slab_cache, (void *)ptr);
> > 
> > It seems slab_cache is not generic for all types of slabs. SLOB does not care about it:
> 
> Oof.  I was sure I checked that.  You're quite right that it doesn't ...
> this should fix that problem:

This patch was complete rubbish.  The point of SLOB is that it mixes
sizes within the same page, and doesn't store the size when allocating
from a slab.  So there is no way to tell.  I'm going to think about this
some more.
