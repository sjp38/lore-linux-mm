Date: Fri, 15 Jun 2007 14:39:06 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] slob: poor man's NUMA, take 5.
Message-ID: <20070615053906.GA28865@linux-sh.org>
References: <20070615033412.GA28687@linux-sh.org> <Pine.LNX.4.64.0706142119540.4224@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706142119540.4224@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 14, 2007 at 09:30:58PM -0700, Christoph Lameter wrote:
> On Fri, 15 Jun 2007, Paul Mundt wrote:
> 
> > This version adds in a slob_def.h and reorders a bit of the slab.h
> > definitions. This should take in to account all of the outstanding
> > comments so far on the earlier versions.
> 
> Why are the comments on kmalloc moved() from slab.h to slob_def.h? The 
> comments are only partially correct. So they probably can do less harm in 
> slob_def.h. May be good if you could move them back and in the process 
> make them accurate?
> 
The comments moved because the kmalloc() definition moved, it didn't seem
entirely helpful to leave the comment by itself and have the definitions
in the *_def.h files.

But I'll try and generalize the comments regarding the allocator gfp
flags, and keep those in slab.h, so it's more obvious (as well as tidying
them for correctness).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
