Subject: Re: [RFC/PATCH] Use mmu_gather for fork() instead of flush_tlb_mm()
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4691FFDC.5020808@yahoo.com.au>
References: <1183952874.3388.349.camel@localhost.localdomain>
	 <1183962981.5961.3.camel@localhost.localdomain>
	 <1183963544.5961.6.camel@localhost.localdomain>
	 <4691E64F.5070506@yahoo.com.au>
	 <1183972349.5961.25.camel@localhost.localdomain>
	 <4691FFDC.5020808@yahoo.com.au>
Content-Type: text/plain
Date: Mon, 09 Jul 2007 19:47:38 +1000
Message-Id: <1183974458.5961.42.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-09 at 19:29 +1000, Nick Piggin wrote:
> They could just #define one to the other though, there are only a
> small
> number of them. Is there a downside to not making them distinct? i386
> for example probably would just keep doing a tlb flush for fork and
> not
> want to worry about touching the tlb gather stuff.

But the tlb gather stuff just does ... a flush_tlb_mm() on x86 :-)

I really think it's the right API

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
