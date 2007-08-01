Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
From: Andi Kleen <andi@firstfloor.org>
Date: 01 Aug 2007 12:44:52 +0200
In-Reply-To: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
Message-ID: <p73myxbpm8r.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi <miklos@szeredi.hu> writes:

> I wonder why we don't have type safe object allocators a-la new() in
> C++ or g_new() in glib?
> 
>   fooptr = k_new(struct foo, GFP_KERNEL);
> 
> is nicer and more descriptive than
> 
>   fooptr = kmalloc(sizeof(*fooptr), GFP_KERNEL);
> 
> and more safe than
> 
>   fooptr = kmalloc(sizeof(struct foo), GFP_KERNEL);

How is it more safe? It seems 100% equivalent to me,
just a different syntax.

> 
> And we have zillions of both variants.

In my own non kernel code i tend to define a pascal style NEW()

#define NEW(p) ((p) = malloc(sizeof(*(p))))

But I'm not sure such a untraditional solution would too popular.

Also I don't think we have too many bugs in this area anyways; so
it might be better to concentrate on more fruitful areas.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
