From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 0/4] futex: get_user_pages_fast() for shared futexes
Date: Tue, 30 Sep 2008 17:21:51 +1000
References: <20080926173219.885155151@twins.programming.kicks-ass.net> <20080927161712.GA1525@elte.hu>
In-Reply-To: <20080927161712.GA1525@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809301721.52148.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Eric Dumazet <dada1@cosmosbay.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 28 September 2008 02:17, Ingo Molnar wrote:
> * Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > Since get_user_pages_fast() made it in, I thought to give this another
> > try. Lightly tested by disabling the private futexes and running some
> > java proglets.
>
> hm, very interesting. Since this is an important futex usecase i started
> testing it in tip/core/futexes:
>
>  cd33272: futex: cleanup fshared
>  a135356: futex: use fast_gup()
>  39ce77b: futex: reduce mmap_sem usage
>  0d7a336: futex: rely on get_user_pages() for shared futexes
>
> Nick, it would be nice to get an Acked-by/Reviewed-by from you, before
> we think about whether it should go upstream.

Yeah, these all look pretty good. It's nice to get rid of mmap sem here.

Which reminds me, we need to put a might_lock mmap_sem into
get_user_pages_fast...

But these patches look good to me (last time we discussed them I thought
there was a race with page truncate, but it looks like you've closed that
by holding page lock over the whole operation...)

Nice work, Peter.

BTW. what kinds of things use inter-process futexes as of now?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
