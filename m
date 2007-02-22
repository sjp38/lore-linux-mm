Date: Thu, 22 Feb 2007 07:25:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: The unqueued Slab allocator
In-Reply-To: <1172133274.6374.12.camel@twins>
Message-ID: <Pine.LNX.4.64.0702220724340.858@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
 <1172133274.6374.12.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Feb 2007, Peter Zijlstra wrote:

> On Wed, 2007-02-21 at 23:00 -0800, Christoph Lameter wrote:
> 
> > +/*
> > + * Lock order:
> > + *   1. slab_lock(page)
> > + *   2. slab->list_lock
> > + *
> 
> That seems to contradict this:

This is a trylock. If it fails then we can compensate by allocating
a new slab.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
