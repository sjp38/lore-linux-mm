Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6B36B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 23:09:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a66so69869394pfl.6
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 20:09:59 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 6si21511341pfe.109.2017.06.01.20.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 01 Jun 2017 20:09:58 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <alpine.LSU.2.11.1706011128490.3622@eggly.anvils>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils> <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org> <alpine.LSU.2.11.1706011002130.3014@eggly.anvils> <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org> <alpine.LSU.2.11.1706011128490.3622@eggly.anvils>
Date: Fri, 02 Jun 2017 13:09:54 +1000
Message-ID: <878tlb2igt.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hugh Dickins <hughd@google.com> writes:

> On Thu, 1 Jun 2017, Christoph Lameter wrote:
>> 
>> Ok so debugging was off but the slab cache has a ctor callback which
>> mandates that the free pointer cannot use the free object space when
>> the object is not in use. Thus the size of the object must be increased to
>> accomodate the freepointer.
>
> Thanks a lot for working that out.  Makes sense, fully understood now,
> nothing to worry about (though makes one wonder whether it's efficient
> to use ctors on high-alignment caches; or whether an internal "zero-me"
> ctor would be useful).

Or should we just be using kmem_cache_zalloc() when we allocate from
those slabs?

Given all the ctor's do is memset to 0.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
