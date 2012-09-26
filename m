Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 51BC66B005D
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 10:57:23 -0400 (EDT)
Date: Wed, 26 Sep 2012 14:57:21 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com>
Message-ID: <0000013a03150b18-b7c1bfbe-967f-4c33-86e0-f3ca344706cd-000000@email.amazonses.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 25 Sep 2012, David Rientjes wrote:

> Nack, this is already handled by CREATE_MASK in the mm/slab.c allocator;

CREATE_MASK defines legal flags that can be specified. Other flags cause
and error. This is about flags that are internal that should be ignored
when specified.

I think it makes sense to reserve some top flags for internal purposes.

> the flag extensions beyond those defined in the generic slab.h header are
> implementation defined.  It may be true that SLAB uses a bit only
> internally (and already protects it with a BUG_ON() in
> __kmem_cache_create()) but that doesn't mean other implementations can't
> use such a flag that would be a no-op on another allocator.

Other implementations such as SLUB also use the bits in that high range.

Simply ignoring the internal bits on cache creation if they are set is
IMHO not a bit issue and simplifies Glaubers task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
