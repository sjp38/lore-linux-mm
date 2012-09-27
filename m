Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 7DDE46B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 09:57:17 -0400 (EDT)
Date: Thu, 27 Sep 2012 13:57:16 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <alpine.DEB.2.00.1209261810180.7072@chino.kir.corp.google.com>
Message-ID: <0000013a0804637a-82ca7649-bc6c-42ef-9a2c-e79b63f47a23-000000@email.amazonses.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com>
 <0000013a03150b18-b7c1bfbe-967f-4c33-86e0-f3ca344706cd-000000@email.amazonses.com> <alpine.DEB.2.00.1209261810180.7072@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 26 Sep 2012, David Rientjes wrote:

> On Wed, 26 Sep 2012, Christoph Lameter wrote:
>
> > > Nack, this is already handled by CREATE_MASK in the mm/slab.c allocator;
> >
> > CREATE_MASK defines legal flags that can be specified. Other flags cause
> > and error. This is about flags that are internal that should be ignored
> > when specified.
> >
>
> That should be ignored for the mm/slab.c allocator, yes.

Then you are ok with the patch as is?


> > I think it makes sense to reserve some top flags for internal purposes.
> >
>
> It depends on the implementation: if another slab allocator were to use
> additional bits that would be a no-op with mm/slab.c, then this patch
> would be too restrictive.  There's also no requirement that any "internal
> flags" reserved by a slab allocator implementation must be shared in the
> same kmem_cache field as the flags passed to kmem_cache_create() -- it's
> actually better if they aren't since they seldom need to be accessed in
> the same cacheline.

There *are* multiple slab allocators using those bits! And this works for
them. There is nothing too restrictive here. The internal flags are
standardized by this patch to be in the highest nibble.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
