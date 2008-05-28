Date: Wed, 28 May 2008 10:58:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Subject: Slab allocators: Remove kmem_cache_name() to fix invalid
 frees
In-Reply-To: <1211997084.31329.155.camel@calx>
Message-ID: <Pine.LNX.4.64.0805281057160.29542@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0805281032290.22637@schroedinger.engr.sgi.com>
 <1211997084.31329.155.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, David Miller <davem@davemloft.net>, acme <acme@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 28 May 2008, Matt Mackall wrote:

> Seems it would be better to simply allow either unnamed caches or
> duplicate cache names.

I am fine if we would allow NULL to be passed as a name. But the name is 
useful for debugging purposes.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
