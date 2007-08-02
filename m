In-reply-to: <Pine.LNX.4.64.0708012223520.3265@schroedinger.engr.sgi.com>
	(message from Christoph Lameter on Wed, 1 Aug 2007 22:33:07 -0700
	(PDT))
Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu> <Pine.LNX.4.64.0708012223520.3265@schroedinger.engr.sgi.com>
Message-Id: <E1IGVGf-0000sv-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 02 Aug 2007 09:38:45 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > I wonder why we don't have type safe object allocators a-la new() in
> > C++ or g_new() in glib?
> > 
> >   fooptr = k_new(struct foo, GFP_KERNEL);
> > 
> > is nicer and more descriptive than
> > 
> >   fooptr = kmalloc(sizeof(*fooptr), GFP_KERNEL);
> > 
> > and more safe than
> > 
> >   fooptr = kmalloc(sizeof(struct foo), GFP_KERNEL);
> > 
> > And we have zillions of both variants.
> 
> Hmmm yes I think that would be good. However, please clean up the naming.
> The variant on zeroing on zering get to be too much.

OK, there seems to be a consensus on that ;)

[snip]

> I do not see any _node variants?

Well, those are _very_ rare, I'd only add those if there's a demand
for them.

> The array variants translate into kmalloc anyways and are used
> in an inconsistent manner. Sometime this way sometimes the other. Leave 
> them?

If the too many variants are bothersome, then I'd rather just have the
array variant, and give 1 as an array size for the non-array case.

> 	kcalloc(n, size, flags) == kmalloc(size, flags)
> 
> Then kzalloc is equivalent to adding the __GFP_ZERO flag. Thus
> 
> 	kzalloc(size, flags) == kmalloc(size, flags | __GFPZERO)
> 
> If you define a new flag like GFP_ZERO_ATOMIC and GFP_ZERO_KERNEL you 
> could do
> 
> 	kalloc(struct, GFP_ZERO_KERNEL)
> 
> instead of adding new variants?

I don't really like this, introducing new gfp flags just makes
grepping harder.

I do think that at least having a zeroing and a non-zeroing variant
makes sense.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
