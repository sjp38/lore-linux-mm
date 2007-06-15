Date: Fri, 15 Jun 2007 07:31:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 5.
In-Reply-To: <20070615053906.GA28865@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706150730530.7400@schroedinger.engr.sgi.com>
References: <20070615033412.GA28687@linux-sh.org>
 <Pine.LNX.4.64.0706142119540.4224@schroedinger.engr.sgi.com>
 <20070615053906.GA28865@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jun 2007, Paul Mundt wrote:

> The comments moved because the kmalloc() definition moved, it didn't seem
> entirely helpful to leave the comment by itself and have the definitions
> in the *_def.h files.

That is helpful because someone will be first looking at slab.h to find 
the general API. The description is not SLAB, SLUB or SLOB specific.
 
> But I'll try and generalize the comments regarding the allocator gfp
> flags, and keep those in slab.h, so it's more obvious (as well as tidying
> them for correctness).

Great.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
