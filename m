Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id BD3B76B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 10:20:14 -0400 (EDT)
Date: Fri, 28 Sep 2012 14:20:13 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK1 [07/13] slab: Use common kmalloc_index/kmalloc_size
 functions
In-Reply-To: <50656196.2000101@parallels.com>
Message-ID: <0000013a0d3fc2e2-edc137eb-088a-40cc-a853-a8d9e5242667-000000@email.amazonses.com>
References: <20120926200005.911809821@linux.com> <0000013a043aca15-00293133-8d9b-469d-afa7-b00ac0bf1015-000000@email.amazonses.com> <50656196.2000101@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> One nitpick:
>
> >
> > @@ -185,26 +169,19 @@ static __always_inline void *kmalloc_nod
> >  	struct kmem_cache *cachep;
> >
> >  	if (__builtin_constant_p(size)) {
> > -		int i = 0;
> > +		int i;
> >
>
> Although this is technically correct, the former is correct as well, and
> this end up only adding churn to the patch.

What does the "former" refer to?

> Should you decide to remove it, there is another instance of this a bit
> more down.

Remove what?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
