Date: Mon, 4 Sep 2000 12:23:00 +0100 (BST)
From: Tigran Aivazian <tigran@veritas.com>
Subject: Re: stack overflow
In-Reply-To: <20000904140325.Y22907@mea-ext.zmailer.org>
Message-ID: <Pine.LNX.4.21.0009041219241.1639-100000@saturn.homenet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Cc: Zeshan Ahmad <zeshan_uet@yahoo.com>, linux-mm@kvack.org, Mark Hemment <markhe@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Sep 2000, Matti Aarnio wrote:
> > when the function kmem_cache_sizes_init is called in
> > /init/main.c The exact place where the stack overflow
> > occurs is in the function kmem_cache_slabmgmt in
> > /mm/slab.c
> > 
> > Is there any way to change the stack size in Kernel?
> > Can the change in stack size simply solve this Kernel
> > stack overflow problem?
> 
> 	That is indicative that somewhere along the path
> 	you are:  a) recursin

looking at the code, it seems in theory possible to recurse via
kmem_cache_alloc()->kmem_cache_grow()->kmem_cache_slabmgmt()->kmem_cache_alloc() but
I thought Mark invented offslab_limit to prevent this.

Maybe decreasing offslab_limit can help? Defer to Mark...

Regards,
Tigran

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
