Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id AB4476B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 11:00:22 -0400 (EDT)
Date: Wed, 8 Aug 2012 09:59:11 -0500 (CDT)
From: "Christoph Lameter (Open Source)" <cl@linux.com>
Subject: Re: Common10 [10/20] Move duping of slab name to slab_common.c
In-Reply-To: <CAAmzW4MoHp9YXg1Y48edh2TEdR8wUYYdxE7nq5WkgCRb9fRUXw@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1208080953500.7756@greybox.home>
References: <20120803192052.448575403@linux.com> <20120803192153.623879087@linux.com> <CAAmzW4MoHp9YXg1Y48edh2TEdR8wUYYdxE7nq5WkgCRb9fRUXw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Sun, 5 Aug 2012, JoonSoo Kim wrote:

> We can remove some comment for name param of  __kmem_cache_create() in slab.c.

Ok.

> We need to remove CONFIG_DEBUG_VM for out_locked now,
> although later patch handles it.

Ok.

> > +       } else {
> > +               kfree(n);
> > +               err = -ENOSYS; /* Until __kmem_cache_create returns code */
> > +       }
>
> In mergeable case, leak for name is possible.
> __kmem_cache_create() doesn't set name to s->name in mergeable case.
> So, this memory can't be freed.

If __kmem_cache_create() finds a mergeable cache and returns a pointer
to another cache then then this branch wont be taken since s != NULL.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
