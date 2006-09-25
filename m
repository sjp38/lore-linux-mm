Date: Sun, 24 Sep 2006 20:46:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: One idea to free up page flags on NUMA
In-Reply-To: <200609250504.58427.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0609242041210.19943@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
 <200609240924.42382.ak@suse.de> <Pine.LNX.4.64.0609241730470.19511@schroedinger.engr.sgi.com>
 <200609250504.58427.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2006, Andi Kleen wrote:

> > Right could be in highmem and thus would free up around 20 Megabytes of 
> > low memory.
> But won't the vmemmap need more than the 20MB?

It will need the same as the regular mmap + one / two page table pages 
pointing to the huge pages of the virtual memmap. So if one goes from 
regular mmap to virtual mmap one pays with a few page table pages and the 
need for additional TLBs for lookup. But one can remove the memmap 
entirely from the low memory area.

If we upgrade sparse to be able to use vmemmap then we trade the 
existing sparse structures against the few page table pages plus the 
TLB overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
