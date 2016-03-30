Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9AC916B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:10:59 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id zm5so34588209pac.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 01:10:59 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id v71si4779149pfi.22.2016.03.30.01.10.58
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 01:10:59 -0700 (PDT)
Date: Wed, 30 Mar 2016 17:12:58 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 04/11] mm/slab: factor out kmem_cache_node initialization
 code
Message-ID: <20160330081258.GC1678@js1304-P5Q-DELUXE>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459142821-20303-5-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1603281955300.31323@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603281955300.31323@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 28, 2016 at 07:56:15PM -0500, Christoph Lameter wrote:
> On Mon, 28 Mar 2016, js1304@gmail.com wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > -		spin_lock_irq(&n->list_lock);
> > -		n->free_limit =
> > -			(1 + nr_cpus_node(node)) *
> > -			cachep->batchcount + cachep->num;
> > -		spin_unlock_irq(&n->list_lock);
> > +		ret = init_cache_node(cachep, node, GFP_KERNEL);
> > +		if (ret)
> > +			return ret;
> 
> Drop ret and do a
> 
> 	return init_cache_node(...);
> 
> instead?

Will do it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
