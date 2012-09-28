Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 710BA6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:10:21 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:10:20 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <alpine.DEB.2.00.1209271551220.13360@chino.kir.corp.google.com>
Message-ID: <0000013a0d36b332-44a8ef43-b881-4267-bb4b-f2e441ae185c-000000@email.amazonses.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com>
 <0000013a03150b18-b7c1bfbe-967f-4c33-86e0-f3ca344706cd-000000@email.amazonses.com> <alpine.DEB.2.00.1209261810180.7072@chino.kir.corp.google.com> <0000013a0804637a-82ca7649-bc6c-42ef-9a2c-e79b63f47a23-000000@email.amazonses.com>
 <alpine.DEB.2.00.1209271551220.13360@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, David Rientjes wrote:

> No, it's implementation defined so it shouldn't be in kmem_cache_create(),
> it should be in __kmem_cache_create()

The flags are standardized between allocators. We carve out a couple of
bits here that can be slab specific.

> > There *are* multiple slab allocators using those bits! And this works for
> > them. There is nothing too restrictive here. The internal flags are
> > standardized by this patch to be in the highest nibble.
> >
>
> I'm referring to additional slab allocators that will be proposed for
> inclusion shortly.

I am sorry but we cannot consider something that has not been discussed
and publicly reviewed on the mailing list before. We have no way to
understand your rationales at this point and it would take quite some time
to review a new allocator. I would at least have expected the design of
the allocator to be discussed on linux-mm. Nothing of that nature has
happened as far as I can tell.

I think there was a presentation at one of the conference but sadly I was
not able to attend it. I tried to find some details on what was proposed
but so far I have been unsuccessful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
