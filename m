Received: by gxk8 with SMTP id 8so12143572gxk.14
        for <linux-mm@kvack.org>; Tue, 30 Sep 2008 20:13:44 -0700 (PDT)
Message-ID: <a36005b50809302013w54db0985o635bcbef05a9e8f3@mail.gmail.com>
Date: Tue, 30 Sep 2008 20:13:44 -0700
From: "Ulrich Drepper" <drepper@gmail.com>
Subject: Re: [PATCH 0/4] futex: get_user_pages_fast() for shared futexes
In-Reply-To: <48E205BE.8030908@cosmosbay.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080926173219.885155151@twins.programming.kicks-ass.net>
	 <20080927161712.GA1525@elte.hu>
	 <200809301721.52148.nickpiggin@yahoo.com.au>
	 <1222764669.12646.26.camel@twins.programming.kicks-ass.net>
	 <48E205BE.8030908@cosmosbay.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 30, 2008 at 3:55 AM, Eric Dumazet <dada1@cosmosbay.com> wrote:
> I am not sure how it could be converted to private futexes, since
> old binaries (static glibc) will use FUTEX_WAKE like calls.

We considered this back when but any effort seems too much.  We'd
either need a clone flag (a scarce resource) or replace the set_tid
_address syscall.  Given that the futex is woken once per thread
lifetime it shouldn't be an issue.  If the semaphore shows up even
after this patch feel free to introduce a new set_tid_address syscall.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
