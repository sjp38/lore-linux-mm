Date: Sun, 24 Sep 2000 22:26:11 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: mingo@elte.hu
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
In-Reply-To: <20000924222431.C5571@athlon.random>
Message-ID: <Pine.LNX.4.21.0009242225300.8705-100000@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 24 Sep 2000, Andrea Arcangeli wrote:

> >  - do shrink_[d|i]cache_memory() even if !__GFP_IO. This improves balance.
> 
> It will deadlock. (that same mistake was dealdocking early 2.2.x too btw)

where will it deadlock?

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
