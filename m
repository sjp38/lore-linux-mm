Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id E96AC6B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 14:42:49 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so710526qcs.14
        for <linux-mm@kvack.org>; Tue, 14 Aug 2012 11:42:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1208080953500.7756@greybox.home>
References: <20120803192052.448575403@linux.com>
	<20120803192153.623879087@linux.com>
	<CAAmzW4MoHp9YXg1Y48edh2TEdR8wUYYdxE7nq5WkgCRb9fRUXw@mail.gmail.com>
	<alpine.DEB.2.02.1208080953500.7756@greybox.home>
Date: Wed, 15 Aug 2012 03:42:48 +0900
Message-ID: <CAAmzW4Nw-7b3cR-oL___LsPHx6ZM7QgoOMFGaXJiWzmfHkYNxw@mail.gmail.com>
Subject: Re: Common10 [10/20] Move duping of slab name to slab_common.c
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Christoph Lameter (Open Source)" <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

2012/8/8 Christoph Lameter (Open Source) <cl@linux.com>:
> On Sun, 5 Aug 2012, JoonSoo Kim wrote:
>
>> We can remove some comment for name param of  __kmem_cache_create() in slab.c.
>
> Ok.
>
>> We need to remove CONFIG_DEBUG_VM for out_locked now,
>> although later patch handles it.
>
> Ok.
>
>> > +       } else {
>> > +               kfree(n);
>> > +               err = -ENOSYS; /* Until __kmem_cache_create returns code */
>> > +       }
>>
>> In mergeable case, leak for name is possible.
>> __kmem_cache_create() doesn't set name to s->name in mergeable case.
>> So, this memory can't be freed.
>
> If __kmem_cache_create() finds a mergeable cache and returns a pointer
> to another cache then then this branch wont be taken since s != NULL.

I means that if we find mergeable cache, we don't use n (from
kstrdup), but it is already allocated.
So it should be freed in this case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
