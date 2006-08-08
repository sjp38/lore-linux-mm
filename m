Date: Tue, 8 Aug 2006 10:59:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
In-Reply-To: <20060808104752.3e7052dd.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0608081052460.28259@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0608081748070.24142@skynet.skynet.ie>
 <Pine.LNX.4.64.0608081001220.27866@schroedinger.engr.sgi.com>
 <20060808104752.3e7052dd.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: mel@csn.ul.ie, akpm@osdl.org, linux-mm@kvack.org, jes@sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006, Paul Jackson wrote:

> So far, only alloc_pages_exact_node is needed, not "a whole selection."

Ok then we can only allocate pages on exactly one node only via this 
particular function call and not through other subsystem allocators. This 
may fit the urgent needs for node specific allocations that I found so 
far.

However, doing so  means we cannot get vmalloced memory on a 
particular node, we cannot get dma memory on a particular node. We cannot 
indicate to the slab allocator that we want memory on a particular node. 
These are all things that we need. If we would look at the users at all 
the _node allocators then we surely will find users of kmalloc_node and 
vmalloc_node etc that expect memory on exactly that node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
