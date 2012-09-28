Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 560036B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 13:11:28 -0400 (EDT)
Date: Fri, 28 Sep 2012 17:11:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK1 [10/13] Do not define KMALLOC array definitions for SLOB
In-Reply-To: <50656374.8080600@parallels.com>
Message-ID: <0000013a0ddc85ee-584776e4-4456-4436-900a-936830d277b9-000000@email.amazonses.com>
References: <20120926200005.911809821@linux.com> <0000013a043aca17-be81d17b-47c7-4511-9a52-853a493a0437-000000@email.amazonses.com> <50656374.8080600@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri, 28 Sep 2012, Glauber Costa wrote:

> >  /* Create a cache during boot when no slab services are available yet */
> >  void __init create_boot_cache(struct kmem_cache *s, const char *name, size_t size,
> >  		unsigned long flags)
> I don't see why you can't fold this directly in the patch where those
> things are created.

True.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
