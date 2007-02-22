Date: Thu, 22 Feb 2007 07:15:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: The unqueued Slab allocator
In-Reply-To: <84144f020702220249k37306252q627bf3ceb28e8b5d@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0702220712440.757@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
 <84144f020702220249k37306252q627bf3ceb28e8b5d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Feb 2007, Pekka Enberg wrote:

> On 2/22/07, Christoph Lameter <clameter@sgi.com> wrote:
> > This is a new slab allocator which was motivated by the complexity of the
> > existing code in mm/slab.c. It attempts to address a variety of concerns
> > with the existing implementation.
> 
> So do you want to add a new allocator or replace slab?

Add. The performance and quality is not comparable to SLAB at this point.

> On 2/22/07, Christoph Lameter <clameter@sgi.com> wrote:
> > B. Storage overhead of object queues
> 
> Does this make sense for non-NUMA too? If not, can we disable the
> queues for NUMA in current slab?

Given the locking scheme in the current slab you cannot do that. Otherwise
there will be a single lock taken for every operation limiting performace

> On 2/22/07, Christoph Lameter <clameter@sgi.com> wrote:
> > C. SLAB metadata overhead
> 
> Can be done for the current slab code too, no?

The per slab metadata of the SLAB does not fit into the page_struct. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
