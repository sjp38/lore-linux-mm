Date: Sat, 27 Sep 2008 18:17:12 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/4] futex: get_user_pages_fast() for shared futexes
Message-ID: <20080927161712.GA1525@elte.hu>
References: <20080926173219.885155151@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080926173219.885155151@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Eric Dumazet <dada1@cosmosbay.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Since get_user_pages_fast() made it in, I thought to give this another 
> try. Lightly tested by disabling the private futexes and running some 
> java proglets.

hm, very interesting. Since this is an important futex usecase i started 
testing it in tip/core/futexes:

 cd33272: futex: cleanup fshared
 a135356: futex: use fast_gup()
 39ce77b: futex: reduce mmap_sem usage
 0d7a336: futex: rely on get_user_pages() for shared futexes

Nick, it would be nice to get an Acked-by/Reviewed-by from you, before 
we think about whether it should go upstream.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
