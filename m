Message-ID: <439D2135.4050804@yahoo.com.au>
Date: Mon, 12 Dec 2005 18:05:25 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC 1/6] Framework
References: <20051210005440.3887.34478.sendpatchset@schroedinger.engr.sgi.com> <20051210005445.3887.94119.sendpatchset@schroedinger.engr.sgi.com> <439CF2A2.60105@yahoo.com.au> <20051212035631.GX11190@wotan.suse.de> <439CF93D.5090207@yahoo.com.au> <20051212042142.GZ11190@wotan.suse.de> <439CFC67.4030107@yahoo.com.au> <20051212045146.GA11190@wotan.suse.de>
In-Reply-To: <20051212045146.GA11190@wotan.suse.de>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

>>Then you can't use __local_xxx, and so many architectures will use
>>atomic instructions (the ones who don't are the ones with tripled
>>cacheline footprint of this structure).
> 
> 
> They are wrong then. atomic instructions is the wrong implementation
> and they would be better off with asm-generic. 
> 

Yes I mean atomic and per-cpu. Same as asm-generic.

> If anything they should use per_cpu counters for interrupts and 
> use seq locks.

How would seqlocks help?

> Or just turn off the interrupts for a short time
> in the low level code.
> 

This is exactly what mod_page_state does, which is what my patches
eliminate. For a small but significant performance improvement.

> 
>>Sure i386 and x86-64 are happy, but this would probably slow down
>>most other architectures.
> 
> 
> I think it is better to fix the other architectures then - if they
> are really using a full scale bus lock for this they're just wrong.
> 
> I don't think it is a good idea to do a large change in generic
> code just for dumb low level code.
> 

It is not a large change at all, just some shuffling of mod_page_state
and friends to go under pre-existing interrupts-off sections.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
