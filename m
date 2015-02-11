Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id B6B766B006C
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 17:04:34 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id f10so2497629yha.8
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:04:34 -0800 (PST)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id v5si2420610qat.109.2015.02.11.14.04.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 11 Feb 2015 14:04:33 -0800 (PST)
Date: Wed, 11 Feb 2015 16:04:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
In-Reply-To: <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1502111603360.15061@gentwo.org>
References: <20150210194804.288708936@linux.com> <20150210194811.787556326@linux.com> <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com> <alpine.DEB.2.11.1502111243380.3887@gentwo.org>
 <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 11 Feb 2015, David Rientjes wrote:

> > >
> > > Hmm, not sure why the allocator would be required to do the
> > > EXPORT_SYMBOL() if it defines kmem_cache_free_array() itself.  This
> >
> > Keeping the EXPORT with the definition is the custom as far as I could
> > tell.
> >
>
> If you do dummy functions for all the allocators, then this should be as
> simple as unconditionally defining kmem_cache_free_array() and doing
> EXPORT_SYMBOL() here and then using your current implementation of
> __kmem_cache_free_array() for mm/slab.c.

That works if I put an EXPORT_SYMBOL in mm/slab_common.c and define the
function in mm/slub.c?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
