Date: Thu, 16 Feb 2006 18:46:00 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback
 list initialization
In-Reply-To: <200602170310.19731.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0602161828090.27424@schroedinger.engr.sgi.com>
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com>
 <200602170310.19731.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, torvalds@osdl.org, akpm@osdl.org, kiran@scalex86.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Feb 2006, Andi Kleen wrote:

> No, in theory not, but changing that would require considerable changes 
> in the NUMA discovery code and I'm not planning to do that for 2.6.16 now.

Are you sure that the kernel can handle nodelists with holes everywhere? 
This is essentially a new feature requiring a review of all uses of 
node ranges.... I'd rather suggest to fix the arch.

> Also I think the generic code ought to handle that anyways. Why should
> we have node bitmaps if they can't have holes?

There are special cases for example in the slab allocator and possibly 
elsewhere too. F.e. have a look at __alloc_percpu which must allocate 
memory for cpus on offline nodes. These will then never be used. So 
hopefully not an issue just a waste of memory. There is more in 
alloc_alien_cache(). That is just the stuff that I know about off hand. 

> > ia64 has a lookup table. 
> x86-64 too.

So this is fixable in arch specific code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
