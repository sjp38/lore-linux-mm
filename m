Date: Mon, 3 Oct 2005 08:24:43 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH] per-page SLAB freeing (only dcache for now)
In-Reply-To: <20051001215254.GA19736@xeon.cnet>
Message-ID: <Pine.LNX.4.62.0510030823420.7812@schroedinger.engr.sgi.com>
References: <20050930193754.GB16812@xeon.cnet>
 <Pine.LNX.4.62.0509301934390.31011@schroedinger.engr.sgi.com>
 <20051001215254.GA19736@xeon.cnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, akpm@osdl.org, dgc@sgi.com, dipankar@in.ibm.com, mbligh@mbligh.org, manfred@colorfullife.com
List-ID: <linux-mm.kvack.org>

On Sat, 1 Oct 2005, Marcelo wrote:

> I thought about having a mini-API for this such as "struct slab_reclaim_ops" 
> implemented by each reclaimable cache, invoked by a generic SLAB function.
> 
> Problem is that locking involved into looking at the SLAB elements is 
> cache specific (eg dcache_lock for the dcache, inode_lock for the icache, 
> and so on), so making a generic function seems pretty tricky, ie. you 
> need cache specific information in the generic function which is not so 
> easily "generifiable", if there's such a word.

The locking could be done by the cache specific free function. If it 
cannot lock it can simply indicate tha the entry is not freeable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
