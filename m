Date: Thu, 22 Mar 2001 09:36:48 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Thinko in kswapd?
In-Reply-To: <20010322145810.A7296@redhat.com>
Message-ID: <Pine.LNX.4.31.0103220931330.18728-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, arjanv@redhat.com
List-ID: <linux-mm.kvack.org>


On Thu, 22 Mar 2001, Stephen C. Tweedie wrote:
>
> There is what appears to be a simple thinko in kswapd.  We really
> ought to keep kswapd running as long as there is either a free space
> or an inactive page shortfall; but right now we only keep going if
> _both_ are short.

Hmm.. The comment definitely says "or", so changing it to "and" in the
sources makes the comment be non-sensical.

I suspect that the comment and the code were true at some point. The
behaviour of "do_try_to_free_pages()" has changed, though, and I suspect
your suggested change makes more sense now (it certainly seems to be
logical to have the reverse condition for sleeping and for when to call
"do_try_to_free_pages()").

The only way to know is to test the behaviour. My only real worry is that
kswapd might end up eating too much CPU time and make the system feel bad,
but on the other hand the same can certainly be true from _not_ doing this
change too.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
