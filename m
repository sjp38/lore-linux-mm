Date: Wed, 24 Jul 2002 18:21:07 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] updated low-latency zap_page_range
In-Reply-To: <1027559785.17950.3.camel@sinai>
Message-ID: <Pine.LNX.4.44.0207241820170.5944-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Andrew Morton <akpm@zip.com.au>, riel@conectiva.com.br, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 24 Jul 2002, Robert Love wrote:
>
> 	if (preempt_count() == 1 && need_resched())
>
> Then we get "if (0 && ..)" which should hopefully be evaluated away.

I think preempt_count() is not unconditionally 0 for non-preemptible
kernels, so I don't think this is a compile-time constant.

That may be a bug in preempt_count(), of course.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
