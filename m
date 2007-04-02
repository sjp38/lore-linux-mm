Date: Mon, 2 Apr 2007 10:34:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <200704021914.07541.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0704021032150.31053@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
 <200704021744.39880.ak@suse.de> <Pine.LNX.4.64.0704020851300.30394@schroedinger.engr.sgi.com>
 <200704021914.07541.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Andi Kleen wrote:

> > No no no. For the gazillions time: All of 1-1 mapped kernel memory on 
> > x86_64 needs a 2 MB page table entry. The virtual memmap uses the same. 
> > There are *no* additional TLBs used.
> 
> But why do you reserve an own virtual area then if you claim to not use any
> additional mappings? 

The 1-1 area using mappings for 2MB pages right? So it uses a virtual 1-1 
area. It already has a virtual mapping.

What we do for virtual memmap here is also use 2MB pages but order the 
pages a bit different so that they provide a linear memory map.

So the number of TLBs in use stays the same. There are a few additional 
higher level page table pages that are needed to provide the alternate 
view that generates the linear mapping but that is just a couple of pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
