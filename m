Date: Mon, 2 Oct 2000 13:06:56 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [highmem bug report against -test5 and -test6] Re: [PATCH] Re:
 simple FS application that hangs 2.4-test5, mem mgmt problem or FS buffer
 cache mgmt problem? (fwd)
In-Reply-To: <20001002215628.D21473@athlon.random>
Message-ID: <Pine.LNX.4.10.10010021305210.826-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Rik van Riel <riel@conectiva.com.br>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>


On Mon, 2 Oct 2000, Andrea Arcangeli wrote:
> On Mon, Oct 02, 2000 at 04:35:43PM -0300, Rik van Riel wrote:
> > because we keep the buffer heads on active pages in memory...
> 
> A page can be the most active and the VM and never need bh on it after the
> first pagein. Keeping the bh on it means wasting tons of memory for no good
> reason.

I agree. Most of the time, there's absolutely no point in keeping the
buffer heads around. Most pages (and _especially_ the actively mapped
ones) do not need the buffer heads at all after creation - once they are
uptodate they stay uptodate and we're only interested in the page, not the
buffers used to create it.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
