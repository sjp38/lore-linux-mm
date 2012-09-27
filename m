Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 1D5AE6B0069
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 18:52:13 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so2005695pad.14
        for <linux-mm@kvack.org>; Thu, 27 Sep 2012 15:52:12 -0700 (PDT)
Date: Thu, 27 Sep 2012 15:52:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <0000013a0804637a-82ca7649-bc6c-42ef-9a2c-e79b63f47a23-000000@email.amazonses.com>
Message-ID: <alpine.DEB.2.00.1209271551220.13360@chino.kir.corp.google.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com> <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com> <alpine.DEB.2.00.1209251744580.22521@chino.kir.corp.google.com>
 <0000013a03150b18-b7c1bfbe-967f-4c33-86e0-f3ca344706cd-000000@email.amazonses.com> <alpine.DEB.2.00.1209261810180.7072@chino.kir.corp.google.com> <0000013a0804637a-82ca7649-bc6c-42ef-9a2c-e79b63f47a23-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, Christoph Lameter wrote:

> > > > Nack, this is already handled by CREATE_MASK in the mm/slab.c allocator;
> > >
> > > CREATE_MASK defines legal flags that can be specified. Other flags cause
> > > and error. This is about flags that are internal that should be ignored
> > > when specified.
> > >
> >
> > That should be ignored for the mm/slab.c allocator, yes.
> 
> Then you are ok with the patch as is?
> 

No, it's implementation defined so it shouldn't be in kmem_cache_create(), 
it should be in __kmem_cache_create().

> There *are* multiple slab allocators using those bits! And this works for
> them. There is nothing too restrictive here. The internal flags are
> standardized by this patch to be in the highest nibble.
> 

I'm referring to additional slab allocators that will be proposed for 
inclusion shortly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
