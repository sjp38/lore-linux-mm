Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 390EB6B0044
	for <linux-mm@kvack.org>; Tue, 30 Dec 2008 06:27:16 -0500 (EST)
Message-ID: <495A058C.7060105@goop.org>
Date: Tue, 30 Dec 2008 22:27:08 +1100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
References: <49416494.6040009@goop.org> <200707241140.12945.nickpiggin@yahoo.com.au> <49470433.4050504@goop.org> <200812301442.37654.nickpiggin@yahoo.com.au>
In-Reply-To: <200812301442.37654.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> I have patches to move the tlb flushing to an asynchronous process context...
> but all tweaks to that (including flushing at vmap) are just variations on the
> existing flushing scheme and don't solve your problem, so I don't think we
> really need to change that for the moment (my patches are mainly for latency
> improvement and to allow vunmap to be usable from interrupt context).
>   

Well, that's basically what I want - I want to use vunmap in an 
interrupts-disabled context.  Any other possibility of deferring tlb 
flushes is pure bonus and not all that important.

But it also occurred to me that Xen doesn't use IPIs for cross-cpu TLB 
flushes (it goes to hypercall), so it shouldn't be an issue anyway.  I 
haven't had a chance to look at what's really going on there.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
