Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6466B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 08:56:10 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q7so14517950pgr.10
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:56:10 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id b3si23432996plx.365.2017.11.27.05.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Nov 2017 05:56:08 -0800 (PST)
Date: Mon, 27 Nov 2017 05:56:06 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 03/23] slab: create_kmalloc_cache() works with 32-bit
 sizes
Message-ID: <20171127135606.GA30372@bombadil.infradead.org>
References: <20171123221628.8313-1-adobriyan@gmail.com>
 <20171123221628.8313-3-adobriyan@gmail.com>
 <20171124010638.GA3722@bombadil.infradead.org>
 <CACVxJT9gvPK0=q4X9pOBYRkaDmMXy-ON61QhF+ZxqLhTSiNVMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVxJT9gvPK0=q4X9pOBYRkaDmMXy-ON61QhF+ZxqLhTSiNVMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

On Mon, Nov 27, 2017 at 12:21:23PM +0200, Alexey Dobriyan wrote:
> On 11/24/17, Matthew Wilcox <willy@infradead.org> wrote:
> > On Fri, Nov 24, 2017 at 01:16:08AM +0300, Alexey Dobriyan wrote:
> >> -struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t
> >> size,
> >> +struct kmem_cache *__init create_kmalloc_cache(const char *name, unsigned
> >> int size,
> >>  				slab_flags_t flags)
> >
> > Could you reflow this one?  Surprised checkpatch didn't whinge.
> 
> If it doesn't run, it doesn't whinge. :-)
> 
> I think that in the era of 16:9 monitors line length should be ignored
> altogether.

16:9 monitors let me get more 80x24 xterms on one virtual desktop.  Please
stick to the line lengths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
