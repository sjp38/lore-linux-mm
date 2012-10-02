Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id B6AD96B0068
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 10:43:57 -0400 (EDT)
Date: Tue, 2 Oct 2012 14:43:56 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab vs. slub kmem cache name inconsistency
In-Reply-To: <1349170840.10698.14.camel@jlt4.sipsolutions.net>
Message-ID: <0000013a21eee926-56d34b55-4a2f-45cb-a6d8-0dc6b826c867-000000@email.amazonses.com>
References: <1349170840.10698.14.camel@jlt4.sipsolutions.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Berg <johannes@sipsolutions.net>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

This should be fixed the merge window for 3.7. All allocators will do a
kstrdup then.

On Tue, 2 Oct 2012, Johannes Berg wrote:

> Hi,
>
> I just noticed that slub's kmem_cache_create() will kstrdup() the name,
> while slab doesn't. That's a little confusing, since when you look at
> slub you can easily get away with passing a string you built on the
> stack, while that will then lead to very strange results (and possibly
> crashes?) with slab. The slab kernel-doc string always says this:
>
>  * @name must be valid until the cache is destroyed. This implies that
>  * the module calling this has to destroy the cache before getting unloaded.
>
> Is there any reason for this difference, or should slab also kstrdup(),
> or should slub not do it? Or maybe slub should have a "oops, name is on
> stack" warning/check?
>
> johannes
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
