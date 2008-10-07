Message-ID: <48EB7E59.7070308@linux-foundation.org>
Date: Tue, 07 Oct 2008 10:20:57 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [BUG] SLOB's krealloc() seems bust
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>	 <48EB6D2C.30806@linux-foundation.org> <1223391655.13453.344.camel@calx>
In-Reply-To: <1223391655.13453.344.camel@calx>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Matt Mackall wrote:

> We can't dynamically determine whether a pointer points to a kmalloced
> object or not. kmem_cache_alloc objects have no header and live on the
> same pages as kmalloced ones.

Could you do a heuristic check? Assume that this is a kmalloc object and then
verify the values in the small control block? If the values are out of line
then this cannot be a kmalloc'ed object.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
