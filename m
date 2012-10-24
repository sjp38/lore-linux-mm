Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id EBC1D6B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 14:02:33 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id dq12so531230wgb.26
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 11:02:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1351087158-8524-2-git-send-email-glommer@parallels.com>
References: <1351087158-8524-1-git-send-email-glommer@parallels.com>
	<1351087158-8524-2-git-send-email-glommer@parallels.com>
Date: Wed, 24 Oct 2012 21:02:32 +0300
Message-ID: <CAOJsxLHxo7zJk=aWrjmuaYsEkaChTCgXowtHxtuiabaOP3W3-Q@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] kmem_cache: include allocators code directly into slab_common
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>

On Wed, Oct 24, 2012 at 4:59 PM, Glauber Costa <glommer@parallels.com> wrote:
> While the goal of slab_common.c is to have a common place for all
> allocators, we face two different goals that are in opposition to each
> other:
>
> 1) Have the different layouts be the business of each allocator, in
> their .c
> 2) inline as much as we can for fast paths
>
> Because of that, we either have to move all the entry points to the
> mm/slab.h and rely heavily on the pre-processor, or include all .c files
> in here.
>
> The pre-processor solution has the disadvantage that some quite
> non-trivial code gets even more non-trivial, and we end up leaving for
> readers a non-pleasant indirection.
>
> To keep this sane, we'll include the allocators .c files in here.  Which
> means we will be able to inline any code they produced, but never the
> other way around!
>
> Doing this produced a name clash. This was resolved in this patch
> itself.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Joonsoo Kim <js1304@gmail.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Pekka Enberg <penberg@kernel.org>
> CC: Christoph Lameter <cl@linux.com>

So I hate this patch with a passion. We don't have any fastpaths in
mm/slab_common.c nor should we. Those should be allocator specific.

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
