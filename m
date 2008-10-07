Date: Tue, 7 Oct 2008 09:37:27 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [BUG] SLOB's krealloc() seems bust
In-Reply-To: <1223395846.26330.55.camel@lappy.programming.kicks-ass.net>
Message-ID: <alpine.LFD.2.00.0810070924130.3208@nehalem.linux-foundation.org>
References: <1223387841.26330.36.camel@lappy.programming.kicks-ass.net>  <48EB6D2C.30806@linux-foundation.org>  <1223391655.13453.344.camel@calx> <1223395846.26330.55.camel@lappy.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Oct 2008, Peter Zijlstra wrote:
> 
> Tested-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

Heh. Can we get a sign-off and a nice commit message?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
