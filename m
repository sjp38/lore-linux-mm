Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 907606B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 19:35:19 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id bs8so515117wib.4
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 16:35:19 -0800 (PST)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com. [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id fh2si206981wib.100.2015.02.11.16.35.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 16:35:17 -0800 (PST)
Received: by mail-we0-f180.google.com with SMTP id k11so6847856wes.11
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 16:35:17 -0800 (PST)
Date: Wed, 11 Feb 2015 16:35:11 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] Slab infrastructure for array operations
In-Reply-To: <alpine.DEB.2.11.1502111603360.15061@gentwo.org>
Message-ID: <alpine.DEB.2.10.1502111633200.966@chino.kir.corp.google.com>
References: <20150210194804.288708936@linux.com> <20150210194811.787556326@linux.com> <alpine.DEB.2.10.1502101542030.15535@chino.kir.corp.google.com> <alpine.DEB.2.11.1502111243380.3887@gentwo.org> <alpine.DEB.2.10.1502111213151.16711@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1502111603360.15061@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, 11 Feb 2015, Christoph Lameter wrote:

> > > > Hmm, not sure why the allocator would be required to do the
> > > > EXPORT_SYMBOL() if it defines kmem_cache_free_array() itself.  This
> > >
> > > Keeping the EXPORT with the definition is the custom as far as I could
> > > tell.
> > >
> >
> > If you do dummy functions for all the allocators, then this should be as
> > simple as unconditionally defining kmem_cache_free_array() and doing
> > EXPORT_SYMBOL() here and then using your current implementation of
> > __kmem_cache_free_array() for mm/slab.c.
> 
> That works if I put an EXPORT_SYMBOL in mm/slab_common.c and define the
> function in mm/slub.c?
> 

No, my suggestion was for the same pattern as kmem_cache_alloc_array().  
In other words, I think you should leave the definition of 
kmem_cache_free_array() the way it is in your patch, remove the #ifndef 
since _HAVE_SLAB_ALLOCATOR_ARRAY_OPERATIONS is going away, and then define 
a __kmem_cache_free_array() for each allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
