Date: Tue, 12 Jun 2007 22:30:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 2.
In-Reply-To: <20070613042306.GA15462@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706122225190.28451@schroedinger.engr.sgi.com>
References: <20070613031203.GB15009@linux-sh.org> <466F6351.9040503@yahoo.com.au>
 <20070613033306.GA15169@linux-sh.org> <466F66E3.8020200@yahoo.com.au>
 <466F67A4.9080104@yahoo.com.au> <20070613041319.GA15328@linux-sh.org>
 <20070613042306.GA15462@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hmmmm. One key advantage that SLOB has over all allocators is the density 
of the kmalloc array. I tried to add various schemes to SLUB but there is 
still a difference of 340kb on boot. If you get it to do NUMA then may be 
we can get a specialized allocator for the kmalloc array out of all of 
this?

If you focus on the kmalloc array then you can avoid to deal with certain 
other issues

- No ctor, no reclaim accounting, no rcu etc.
- No need to manage partial slabs.
- No slab creation, destruction etc.

Maybe that could done in a pretty compact way and replace the space 
wasting kmalloc arrays in SLAB and SLUB?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
