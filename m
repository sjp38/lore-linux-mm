Date: Sun, 24 Sep 2000 11:39:29 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: __GFP_IO && shrink_[d|i]cache_memory()?
In-Reply-To: <Pine.LNX.4.21.0009242038480.7843-100000@elte.hu>
Message-ID: <Pine.LNX.4.10.10009241138080.783-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sun, 24 Sep 2000, Ingo Molnar wrote:
> 
> i just found this out by example, i'm running the shrink_[i|d]cache stuff
> even if __GFP_IO is not set, and no problems so far. (and much better
> balancing behavior)

Send me the tested patch (and I'd suggest moving the shm_swap() test into
shm_swap() too, so that refill_inactive() gets cleaned up a bit).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
