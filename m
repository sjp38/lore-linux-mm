Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 245A76B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 08:43:07 -0400 (EDT)
Received: by weys10 with SMTP id s10so1254680wey.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 05:43:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALF0-+VXA+4us1CSz5DGcSmKr37SnVF6ZMNbh8iLNsM7VYVnQQ@mail.gmail.com>
References: <1344955130-29478-1-git-send-email-elezegarcia@gmail.com>
	<CALF0-+VXA+4us1CSz5DGcSmKr37SnVF6ZMNbh8iLNsM7VYVnQQ@mail.gmail.com>
Date: Wed, 15 Aug 2012 15:43:05 +0300
Message-ID: <CAOJsxLGN-nZHm3P2ebthV+Hh-MDqY9bdpTrOWLPgXUr_eh+B5A@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, slob: Prevent false positive trace upon
 allocation failure
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Glauber Costa <glommer@parallels.com>

On Wed, Aug 15, 2012 at 3:34 PM, Ezequiel Garcia <elezegarcia@gmail.com> wrote:
> As you can see this patch prevents to trace a kmem event if the allocation
> fails.
>
> I'm still unsure about tracing or not this ones, and I'm considering tracing
> failures, perhaps with return=0 and allocated size=0.
>
> In this case, it would be nice to have SLxB all do the same.
> Right now, this is not the case.
>
> You can see how slob::kmem_cache_alloc_node traces independently
> of the allocation succeeding.
> I have no problem trying a fix for this, but I don't now how to trace
> this cases.
>
> Although it is a corner case, I think it's important to define a clear
> and consistent behaviour to make tracing reliable.

Agreed on consistency. I think it's valuable to be able to trace
allocation failures and let userspace filter them out if they don't
need them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
