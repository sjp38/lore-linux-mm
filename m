Date: Mon, 22 Jul 2002 11:05:10 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] low-latency zap_page_range
In-Reply-To: <1027360686.932.33.camel@sinai>
Message-ID: <Pine.LNX.4.44.0207221103430.2928-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Andrew Morton <akpm@zip.com.au>, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 22 Jul 2002, Robert Love wrote:
>
> Sure.  What do you think of this?

How about adding an "cond_resched_lock()" primitive?

You can do it better as a primitive than as the written-out thing (the
spin_unlock() doesn't need to conditionally test the scheduling point
again, it can just unconditionally call schedule())

And there might be other places that want to drop a lock before scheduling
anyway.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
