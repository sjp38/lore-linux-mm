Date: Fri, 11 May 2007 10:08:56 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/2] convert mmap_sem to a scalable rw_mutex
In-Reply-To: <20070511155621.GA13150@elte.hu>
Message-ID: <Pine.LNX.4.64.0705111008380.32716@schroedinger.engr.sgi.com>
References: <20070511131541.992688403@chello.nl> <20070511155621.GA13150@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@tv-sign.ru>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 11 May 2007, Ingo Molnar wrote:

> given how nice this looks already, have you considered completely 
> replacing rwsems with this? I suspect you could test the correctness of 
> that without doing a mass API changeover, by embedding struct rw_mutex 
> in struct rwsem and implementing kernel/rwsem.c's API that way. (the 
> real patch would just flip it all over to rw-mutexes)

Ummmm... How much memory would that cost on large systems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
