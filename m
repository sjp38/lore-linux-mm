Date: Wed, 25 Jul 2007 11:56:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab API: Remove useless ctor parameter and reorder parameters
In-Reply-To: <84144f020707250333gc1c2f01l24c7b9ff6211a489@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0707251153540.8731@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
 <20070724165914.a5945763.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707241705380.9633@schroedinger.engr.sgi.com>
 <20070724175332.41ade708.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707242009080.3583@schroedinger.engr.sgi.com>
 <84144f020707250333gc1c2f01l24c7b9ff6211a489@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2007, Pekka Enberg wrote:

> We're gonna have API breakage with kmem_cache_ops thing too, right?

Not in the initial envisioned form. The unused pointer argument would have 
simply change type leaving kmem_cache_create as is.

Now we may have to add a function to set the kmem_cache_ops to avoid 
API changes. Or we change the ctor type argument to be kmem_cache_ops * 
(as you wanted earlier). However that would require allocating a 
kmem_cache_ops structure for each slab that uses an initializer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
