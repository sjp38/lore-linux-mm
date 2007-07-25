Date: Tue, 24 Jul 2007 20:15:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Slab API: Remove useless ctor parameter and reorder parameters
In-Reply-To: <20070724175332.41ade708.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707242009080.3583@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707232246400.2654@schroedinger.engr.sgi.com>
 <20070724165914.a5945763.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707241705380.9633@schroedinger.engr.sgi.com>
 <20070724175332.41ade708.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007, Andrew Morton wrote:

> > We just got rid of the destructor parameter of kmem_cache_create.
> 
> Yeah, but that got merged into mainline.  It's too late to merge this one.

The destructor removal was merged last Friday. If we do not do it now then 
we have another API breakage in 2.6.24.

> Honest, it's easier for everyone if we shelve this until late -rc's.

Yes I thought that to be the appropriate time for such things too and I 
wanted to keep things the way they were until 2.6.24. But that no longer 
seems to be the case. The destructor patch was only merged a few days ago 
and it already breaks my other slab patches that I am holding. If we do 
this then lets do a comprehensive job. I do not want to get through 
another cycle of this next time. At some point all this slab API stuff 
should be done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
