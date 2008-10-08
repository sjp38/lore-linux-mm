Subject: Re: [BUG] SLOB's krealloc() seems bust
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1223442947.13453.462.camel@calx>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>
	 <1223441190.13453.459.camel@calx>
	 <200810081554.33651.nickpiggin@yahoo.com.au>
	 <200810081611.30897.nickpiggin@yahoo.com.au>
	 <1223442947.13453.462.camel@calx>
Content-Type: text/plain
Date: Wed, 08 Oct 2008 08:43:40 +0200
Message-Id: <1223448220.1378.13.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>, akpm <akpm@linuxfoundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-10-08 at 00:15 -0500, Matt Mackall wrote:

> Damnit, how many ways can we get confused by these little details? I'll
> spin a final version and run it against the test harness shortly.

So I'll wait with testing for the next version?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
