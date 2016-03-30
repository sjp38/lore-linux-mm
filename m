Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 474A06B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:13:29 -0400 (EDT)
Received: by mail-pf0-f177.google.com with SMTP id x3so36143239pfb.1
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 01:13:29 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g4si4779059pat.65.2016.03.30.01.13.27
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 01:13:28 -0700 (PDT)
Date: Wed, 30 Mar 2016 17:15:27 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 05/11] mm/slab: clean-up kmem_cache_node setup
Message-ID: <20160330081526.GD1678@js1304-P5Q-DELUXE>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459142821-20303-6-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1603281957100.31323@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603281957100.31323@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 28, 2016 at 07:58:29PM -0500, Christoph Lameter wrote:
> On Mon, 28 Mar 2016, js1304@gmail.com wrote:
> 
> >   * This initializes kmem_cache_node or resizes various caches for all nodes.
> >   */
> > -static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
> > +static int setup_kmem_cache_node_node(struct kmem_cache *cachep, gfp_t gfp)
> 
> ... _node_node? Isnt there a better name for it?

I will think it more. Reason I use this naming is that there is other
site that uses this naming convention. I'm just mimicking it. :)
It's very appreaciate if you have a suggestion.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
