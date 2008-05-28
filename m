Subject: Re: Subject: Slab allocators: Remove kmem_cache_name() to fix
	invalid frees
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <Pine.LNX.4.64.0805281032290.22637@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0805281032290.22637@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 28 May 2008 12:51:24 -0500
Message-Id: <1211997084.31329.155.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Pekka J Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, David Miller <davem@davemloft.net>, acme <acme@redhat.com>
List-ID: <linux-mm.kvack.org>

[Adding Arnaldo to cc:]

On Wed, 2008-05-28 at 10:40 -0700, Christoph Lameter wrote:
> Fix:
> 
> Create special fields in the networking structs to store a pointer to
> names of slab generated. The pointer is then used to free the name of
> the slab after the slab was destroyed.
> 
> Drop the support for kmem_cache_name from all slab allocators.

Seems it would be better to simply allow either unnamed caches or
duplicate cache names.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
