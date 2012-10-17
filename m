Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2AC5F6B005A
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 17:07:58 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so8586803pad.14
        for <linux-mm@kvack.org>; Wed, 17 Oct 2012 14:07:57 -0700 (PDT)
Date: Wed, 17 Oct 2012 14:07:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5] slab: Ignore internal flags in cache creation
In-Reply-To: <1350473811-16264-1-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1210171407430.20712@chino.kir.corp.google.com>
References: <1350473811-16264-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 17 Oct 2012, Glauber Costa wrote:

> Some flags are used internally by the allocators for management
> purposes. One example of that is the CFLGS_OFF_SLAB flag that slab uses
> to mark that the metadata for that cache is stored outside of the slab.
> 
> No cache should ever pass those as a creation flags. We can just ignore
> this bit if it happens to be passed (such as when duplicating a cache in
> the kmem memcg patches).
> 
> Because such flags can vary from allocator to allocator, we allow them
> to make their own decisions on that, defining SLAB_AVAILABLE_FLAGS with
> all flags that are valid at creation time.  Allocators that doesn't have
> any specific flag requirement should define that to mean all flags.
> 
> Common code will mask out all flags not belonging to that set.
> 
> [ v2: leave the mask out decision up to the allocators ]
> [ v3: define flags for all allocators ]
> [ v4: move all definitions to slab.h ]
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
