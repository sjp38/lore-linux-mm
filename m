Date: Mon, 8 Sep 2008 13:30:25 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [RESEND] x86_64: add memory hotremove config option
Message-ID: <20080908113025.GF26079@one.firstfloor.org>
References: <20080905215452.GF11692@us.ibm.com> <200809081946.31521.nickpiggin@yahoo.com.au> <20080908103015.GE26079@one.firstfloor.org> <200809082119.32725.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200809082119.32725.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Yasunori Goto <y-goto@jp.fujitsu.com>, Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

> Sorry, by "block", I really mean spin I guess. I mean that the CPU will
> be forced to stop executing due to the page fault during this sequence:

It's hard for NMIs at least. They cannot execute faults.

In the end you would need to define a core kernel which 
cannot be remapped and the rest which can and you end up
with even more micro kernel like mess.

> ptep_clear_flush(ptep)         <--- from here
> set_pte(ptep, newpte)          <--- until here
> 
> for prot RW, the window also would include the memcpy, however if that
> adds too much latency for execute/reads, then it can be mapped RO first,
> then memcpy, then flushed and switched.
>  
> 
> > Then that would be essentially a hypervisor or micro kernel approach.
> 
> What would be? Blocking in interrupts? Or non-linear kernel mapping in

Well in general someone remapping all the memory beyond you.
That's essentially a hypervisor in my book.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
