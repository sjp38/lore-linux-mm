Date: Mon, 2 Oct 2000 21:52:17 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] fix for VM test9-pre,
Message-ID: <20001002215217.C21473@athlon.random>
References: <20001002212521.A21473@athlon.random> <Pine.LNX.4.21.0010021626460.22539-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010021626460.22539-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 02, 2000 at 04:28:48PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ying Chen/Almaden/IBM <ying@almaden.ibm.com>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 02, 2000 at 04:28:48PM -0300, Rik van Riel wrote:
> Yup, indeed. I guess we need some extra logic to prevent the
> system from trying to fill all of low memory with dirty
> pages just because all of the highmem pages are free.

A dirty page is allocated in the HIGHMEM immediatly because it's allocated with
GFP_HIGHMEM (see page_cache_alloc() macro). Only the I/O is slower then
(compared to a non highmem machine) because we need bounce buffers for it (and
that trashes mem bus and it makes the I/O slower but it's not a matter of
virtual memory balancing as far I can see).

> Unfortunately, I DID get a few bug reports about
> 2.4.0-test6 and earlier kernels that DID show this
> bug ...

So that may be yet another MM bug, since I remeber Ying said he didn't seen the
bad behaviour in test6.

> I can dig out the bug report if you want ;)

I read one that you sent to TYTSO and I believe classzone should take care of
that highmem problem.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
