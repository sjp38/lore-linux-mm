Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 292A46B0253
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 05:21:25 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id a142so17710083qkb.0
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 02:21:25 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g11sor18106192qtg.144.2017.11.27.02.21.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 02:21:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171124010638.GA3722@bombadil.infradead.org>
References: <20171123221628.8313-1-adobriyan@gmail.com> <20171123221628.8313-3-adobriyan@gmail.com>
 <20171124010638.GA3722@bombadil.infradead.org>
From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 27 Nov 2017 12:21:23 +0200
Message-ID: <CACVxJT9gvPK0=q4X9pOBYRkaDmMXy-ON61QhF+ZxqLhTSiNVMg@mail.gmail.com>
Subject: Re: [PATCH 03/23] slab: create_kmalloc_cache() works with 32-bit sizes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com

On 11/24/17, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Nov 24, 2017 at 01:16:08AM +0300, Alexey Dobriyan wrote:
>> -struct kmem_cache *__init create_kmalloc_cache(const char *name, size_t
>> size,
>> +struct kmem_cache *__init create_kmalloc_cache(const char *name, unsigned
>> int size,
>>  				slab_flags_t flags)
>
> Could you reflow this one?  Surprised checkpatch didn't whinge.

If it doesn't run, it doesn't whinge. :-)

I think that in the era of 16:9 monitors line length should be ignored
altogether.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
