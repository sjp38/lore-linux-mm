Date: Wed, 2 May 2007 12:34:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <84144f020705021218v7ab2461ala215bbb034475e07@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0705021233240.1543@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021330001.16517@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021017270.32635@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0705021924200.24456@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0705021137210.1027@schroedinger.engr.sgi.com>
 <20070502115725.683ac702.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705021158150.1220@schroedinger.engr.sgi.com>
 <84144f020705021218v7ab2461ala215bbb034475e07@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, haveblue@ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Pekka Enberg wrote:

> On 5/2/07, Christoph Lameter <clameter@sgi.com> wrote:
> > I am the one who has to maintain SLAB and SLUB it seems and I have been
> > dealing with the trio SLAB, SLOB and SLUB for awhile now. Its okay and it
> > will be much easier once the cleanups are in.
> 
> And then there's patches such as kmemleak which would need to target
> all three. Plus it doesn't really make sense for users to select
> between three competiting implementations. Please don't take away our
> high hopes of getting rid of mm/slab.c Christoph =)

SLUB supports kmemleak (actually its quite improved). Switch debugging on 
and try

cat /sys/slab/kmalloc-128/alloc_calls.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
