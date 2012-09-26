Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 6AEF46B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 20:47:00 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so1117146pbb.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 17:46:59 -0700 (PDT)
Date: Tue, 25 Sep 2012 17:46:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 25 Sep 2012, Christoph Lameter wrote:

> > No cache should ever pass those as a creation flags. We can just ignore
> > this bit if it happens to be passed (such as when duplicating a cache in
> > the kmem memcg patches)
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 

Nack, this is already handled by CREATE_MASK in the mm/slab.c allocator; 
the flag extensions beyond those defined in the generic slab.h header are 
implementation defined.  It may be true that SLAB uses a bit only 
internally (and already protects it with a BUG_ON() in 
__kmem_cache_create()) but that doesn't mean other implementations can't 
use such a flag that would be a no-op on another allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
