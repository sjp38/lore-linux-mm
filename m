Date: Sun, 24 Sep 2000 22:24:31 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2
Message-ID: <20000924222431.C5571@athlon.random>
References: <Pine.LNX.4.10.10009241141410.789-100000@penguin.transmeta.com> <Pine.LNX.4.21.0009242103390.7843-200000@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0009242103390.7843-200000@elte.hu>; from mingo@elte.hu on Sun, Sep 24, 2000 at 09:34:43PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Sep 24, 2000 at 09:34:43PM +0200, Ingo Molnar wrote:
>  - do shrink_[d|i]cache_memory() even if !__GFP_IO. This improves balance.

It will deadlock. (that same mistake was dealdocking early 2.2.x too btw)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
