Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4C2FC6B0083
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 03:59:22 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2256885pbb.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 00:59:21 -0700 (PDT)
Date: Thu, 21 Jun 2012 00:59:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] Wipe out CFLGS_OFF_SLAB from flags during initial
 slab creation
In-Reply-To: <1340225959-1966-3-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1206210055360.31077@chino.kir.corp.google.com>
References: <1340225959-1966-1-git-send-email-glommer@parallels.com> <1340225959-1966-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Cristoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 21 Jun 2012, Glauber Costa wrote:

> CFLGS_OFF_SLAB is not a valid flag to be passed to cache creation.
> If we are duplicating a cache - support added in a future patch -
> we will rely on the flags it has stored in itself. That may include
> CFLGS_OFF_SLAB.
> 
> So it is better to clean this flag at cache creation.
> 

I think this should be folded into the patch that allows cache 
duplication, it doesn't make sense to apply right now because 
CFLGS_OFF_SLAB is internal to mm/slab.c and it's not going to be passing 
this to kmem_cache_create() itself yet.

Also, do we care that cache_estimate() uses a formal of type int for flags 
when CFLGS_OFF_SLAB is unsigned long?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
