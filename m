Message-ID: <48EB7192.6090307@linux-foundation.org>
Date: Tue, 07 Oct 2008 09:26:26 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [BUG] SLOB's krealloc() seems bust
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>	 <48EB6D2C.30806@linux-foundation.org> <1223388788.26330.38.camel@lappy.programming.kicks-ass.net>
In-Reply-To: <1223388788.26330.38.camel@lappy.programming.kicks-ass.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

> kernel/module.c: perpcu_modinit() reads:
> 
> 	pcpu_size = kmalloc(sizeof(pcpu_size[0]) * pcpu_num_allocated,
> 			    GFP_KERNEL);
> 
> kernel/module.c: split_block() reads:
> 
> 		new = krealloc(pcpu_size, sizeof(new[0])*pcpu_num_allocated*2,
> 			       GFP_KERNEL);
> 

That code is on the way out btw. cpu_alloc support removes this code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
