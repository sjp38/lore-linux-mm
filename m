Date: Mon, 2 Oct 2000 17:45:25 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <Pine.LNX.4.21.0010022218460.11418-100000@elte.hu>
Message-ID: <Pine.LNX.4.21.0010021744000.1067-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linus Torvalds <torvalds@transmeta.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Oct 2000, Ingo Molnar wrote:
> On Mon, 2 Oct 2000, Linus Torvalds wrote:
> 
> > I agree. Most of the time, there's absolutely no point in keeping the
> > buffer heads around. Most pages (and _especially_ the actively mapped
> > ones) do not need the buffer heads at all after creation - once they
> > are uptodate they stay uptodate and we're only interested in the page,
> > not the buffers used to create it.
> 
> except for writes, there we cache the block # in the bh and do
> not have to call the lowlevel FS repeatedly to calculate the FS
> position of the page.

Would it be "close enough" to simply clear the buffer heads of
clean pages which make it to the front of the active list ?

Or is there another optimisation we could do to make the
approximation even better ?

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
