Date: Mon, 8 Jan 2001 16:28:14 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.21.0101081824480.6087-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101081607440.962-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 8 Jan 2001, Marcelo Tosatti wrote:
> 
> I've removed the free_shortage() of refill_inactive() in the patch.
> 
> Comments are welcome.

One comment: why does refill_inactive() do the shrink_dcache_memory() at
all? Why not just remove that?

do_try_to_free_pages() will do that, and that's where it makes more sense
(shrinking the dcache/icache has absolutely nothing to do with the
inactive list).

Historical code?

Also, we should probably remove the "made_progress" and "count--" from the
swap_out() case, as swap_out() hasn't actually caused pages to be free'd
in a long time.. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
