Date: Mon, 2 Apr 2007 08:54:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <200704021744.39880.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704020851300.30394@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de> <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
 <200704021744.39880.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Andi Kleen wrote:

> > Correct. 2MB worth of struct page is 128 mb of memory. Are there nodes 
> > with smaller amounts of memory? 
> 
> Yes the discontigmem minimum is 64MB and there are some setups
> (mostly with numa emulation) where you end up with nodes that small.

Ok. Then I guess we cannot remove discontigmem.
 
> BTW there is no guarantee the node size is a multiple of 128MB so
> you likely need to handle the overlap case. Otherwise we can 
> get cache corruptions

How does sparsemem handle that?

> Sparsemem is still quite experimental; discontigmem is the default
> on x86-64.

Ok more fodder for preserving the choice.

> > > Do you have any benchmarks numbers to prove it? There seem to be a few
> > > benchmarks where the discontig virt_to_page is a problem
> > > (although I know ways to make it more efficient), and sparsemem
> > > is normally slower. Still some numbers would be good.
> > 
> > You want a benchmark to prove that the removal of memory references and 
> > code improves performance?
> 
> You're just moving them into MMU, not really removing it.  And need more TLB entries.

No no no. For the gazillions time: All of 1-1 mapped kernel memory on 
x86_64 needs a 2 MB page table entry. The virtual memmap uses the same. 
There are *no* additional TLBs used.

> It might be faster or it might not. There are some unexpected issues, like most x86-64 
> CPUs have a quite small number of large TLBs so you can get thrashing etc.
> 
> So numbers with TLB intensive workloads would be good. 

You did not read the descriptions. Sigh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
