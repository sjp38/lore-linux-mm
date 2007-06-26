Date: Tue, 26 Jun 2007 11:19:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 12/26] SLUB: Slab defragmentation core
In-Reply-To: <20070626011831.181d7a6a.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706261114320.18010@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com> <20070618095916.297690463@sgi.com>
 <20070626011831.181d7a6a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Andrew Morton wrote:

> > 	No slab operations may be performed in get_reference(). Interrupts
> 
> s/get_reference/get/, yes?

Correct.

> (What's the smallest sized object slub will create?  4 bytes?)

__alignof__(unsigned long long)

> To hold off a concurrent free while defragging, the code relies upon
> slab_lock() on the current page, yes?

Right.
 
> But slab_lock() isn't taken for slabs whose objects are larger than 
> PAGE_SIZE. How's that handled?

slab lock is always taken. How did you get that idea?

> Overall: looks good.  It'd be nice to get a buffer_head shrinker in place,
> see how that goes from a proof-of-concept POV.

Ok.

> How much testing has been done on this code, and of what form, and with
> what results?

I posted them in the intro of the last full post and then Michael 
Piotrowski did some stress tests.

See http://marc.info/?l=linux-mm&m=118125373320855&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
