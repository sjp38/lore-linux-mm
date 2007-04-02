Date: Mon, 2 Apr 2007 14:31:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Generic Virtual Memmap suport for SPARSEMEM
In-Reply-To: <1175548924.22373.109.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704021428340.2272@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
  <1175547000.22373.89.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021351590.1224@schroedinger.engr.sgi.com>
 <1175548924.22373.109.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Dave Hansen wrote:

> > > Hmmmmmmm.  Can we combine this with sparse_index_alloc()?  Also, why not
> > > just use the slab for this?
> > 
> > Use a slab for page sized allocations? No.
> 
> Why not?  We use it above for sparse_index_alloc() and if it is doing
> something wrong, I'd love to fix it.  Can you elaborate?

The slab allocator purposes is to deliver small sub page sized chunks.
The page allocator is there to allocate pages. Both are optimized for its 
purpose.

> > I just extended this in V2 to also work on IA64. Its pretty generic.
> 
> Can you extend it to work on ppc? ;)

I do not know enough about how ppc handles large pages.

> You haven't posted V2, right?

No tests are still running.

> > > Then, do whatever magic you want in alloc_vmemmap().
> > 
> > That would break if alloc_vmemmap returns NULL because it cannot allocate 
> > memory.
> 
> OK, that makes sense.  However, it would still be nice to hide that
> #ifdef somewhere that people are a bit less likely to run into it.  It's
> just one #ifdef, so if you can kill it, great.  Otherwise, they pile up
> over time and _do_ cause real readability problems.

Well think about how to handle the case that the allocatiopn of a page 
table page or a vmemmap block fails. Once we have that sorted out then we 
can cleanup the higher layers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
