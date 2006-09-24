Date: Sat, 23 Sep 2006 18:57:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: One idea to free up page flags on NUMA
In-Reply-To: <200609232043.10434.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0609231845380.16383@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
 <200609231804.40348.ak@suse.de> <Pine.LNX.4.64.0609230937140.15303@schroedinger.engr.sgi.com>
 <200609232043.10434.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Sat, 23 Sep 2006, Andi Kleen wrote:

> > I just looked at the arch code for i386 and x86_64 and it seems that both 
> > already have page tables for all of memory. 
> 
> i386 doesn't map all of memory.

Hmmm... It only maps the kernel text segment?


> > It seems that a virtual memmap  
> > like this would just eliminate sparse overhead and not add any additional 
> > page table overhead.
> 
> You would have new mappings with new overhead, no?

If mappings already exist then this would just mean using the existing 
mappings to implement a virtual memmap array. If 386 has no mappings for
the kernel mappings then this may add more overhead. However, we would be 
using the MMU which would be faster than manually simulating MMU like
lookups as sparse does now. I think sparsemem could be modified to use
the page table format. The sparsemem infrastructure would still work.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
