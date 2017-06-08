Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8C0C6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 01:52:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n81so11515418pfb.14
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 22:52:39 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id l8si3558485plk.333.2017.06.07.22.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Jun 2017 22:52:39 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.DEB.2.20.1706020931080.28919@east.gentwo.org>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils> <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org> <alpine.LSU.2.11.1706011002130.3014@eggly.anvils> <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org> <alpine.LSU.2.11.1706011128490.3622@eggly.anvils> <alpine.DEB.2.20.1706020931080.28919@east.gentwo.org>
Date: Thu, 08 Jun 2017 15:52:35 +1000
Message-ID: <87a85jdo0s.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Christoph Lameter <cl@linux.com> writes:

> On Thu, 1 Jun 2017, Hugh Dickins wrote:
>
>> Thanks a lot for working that out.  Makes sense, fully understood now,
>> nothing to worry about (though makes one wonder whether it's efficient
>> to use ctors on high-alignment caches; or whether an internal "zero-me"
>> ctor would be useful).
>
> Use kzalloc to zero it.

But that's changing a per slab creation memset into a per object
allocation memset, isn't it?

> And here is another example of using slab allocations for page frames.
> Use the page allocator for this? The page allocator is there for
> allocating page frames. The slab allocator main purpose is to allocate
> small objects....

Well usually they are small (< PAGE_SIZE), because we have 64K pages.

But we could rework the code to use the page allocator on 4K configs.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
