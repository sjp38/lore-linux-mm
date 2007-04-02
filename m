Date: Mon, 2 Apr 2007 14:28:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <1175548086.22373.99.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
  <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
  <1175544797.22373.62.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
 <1175548086.22373.99.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Dave Hansen wrote:

> On Mon, 2007-04-02 at 13:30 -0700, Christoph Lameter wrote:
> > On Mon, 2 Apr 2007, Dave Hansen wrote:
> > > I completely agree, it looks like it should be faster.  The code
> > > certainly has potential benefits.  But, to add this neato, apparently
> > > more performant feature, we unfortunately have to add code.  Adding the
> > > code has a cost: code maintenance.  This isn't a runtime cost, but it is
> > > a real, honest to goodness tradeoff.
> > 
> > Its just the opposite. The vmemmap code is so efficient that we can remove 
> > lots of other code and gops of these alternate implementations.
> 
> We do want to make sure that there isn't anyone relying on these.  Are
> you thinking of simple sparsemem vs. extreme vs. sparsemem vmemmap?  Or,
> are you thinking of sparsemem vs. discontig?

I am thinking sparsemem default and then get rid discontig, flatmem etc.
On many platforms this will work. Flatmem for embedded could just be a 
variation on sparse_virtual.

> Amen, brother.  I'd love to see DISCONTIG die, with sufficient testing,
> of course.  Andi, do you have any ideas on how to get sparsemem out of
> the 'experimental' phase?

Note that these arguments on DISCONTIG are flame bait for many SGIers. 
We usually see this as an attack on DISCONTIG/VMEMMAP which is the 
existing best performing implementation for page_to_pfn and vice 
versa. Please lets stop the polarization. We want one consistent scheme 
to manage memory everywhere. I do not care what its called as long as it 
covers all the bases and is not a glaring performance regresssion (like 
SPARSEMEM so far).

> I have noticed before that sparsemem should be able to cover the flatmem
> case if we make MAX_PHYSMEM_BITS == SECTION_SIZE_BITS and massage from
> there.  

Right. But for embedded the memorymap base cannot be constant because 
they may not be able to have a fixed address in memory. So memory map 
needs to become a variable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
