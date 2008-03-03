Message-ID: <47CC822E.8040702@cs.helsinki.fi>
Date: Tue, 04 Mar 2008 00:56:46 +0200
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 7/8] slub: Make the order configurable for each slab cache
References: <20080229044803.482012397@sgi.com>  <20080229044820.044485187@sgi.com> <47C7BEA8.4040906@cs.helsinki.fi>  <Pine.LNX.4.64.0802291137140.11084@schroedinger.engr.sgi.com> <84144f020803010147y489b06fdx479ed0af931de08b@mail.gmail.com> <Pine.LNX.4.64.0803030947300.6010@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803030947300.6010@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 1 Mar 2008, Pekka Enberg wrote:
> 
>> I am not sure I understand what you mean here. For example, for a
>> cache that requires minimum order of 1 to fit any objects (which
>> doesn't happen now because of page allocator pass-through), the
>> order_store() function can call calculate_sizes() with forced_order
> 
> It does happen because the page allocator pass through is only possible 
> for kmalloc allocations.
> 
>> set to zero after which the cache becomes useless. That deserves a
>> code comment, I think.
> 
> If the object does not fit into a page then calculate_sizes will violate 
> max_order (if necessary) in order to make sure that an allocation is 
> possible.

Hmm, I seem to be missing something here. For page size of 4KB, object 
size of 8KB, and min_order of zero, when I write zero order to 
/sys/kernel/slab/<cache>/order the kernel won't crash because...?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
