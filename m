Date: Mon, 16 Aug 1999 23:39:12 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <Pine.LNX.4.10.9908170100030.13378-100000@laser.random>
Message-ID: <Pine.LNX.4.10.9908162331400.1048-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 17 Aug 1999, Andrea Arcangeli wrote:
>
> This other incremental patch will make the bigmem code safe w.r.t. raw-io:

Well, it makes it safe, but doesn't actually make it _work_. As such, it's
not very usable. I suspect it had better be our current fix, though.

I also suspect that we can't just break all drivers, so for now I would
just make this work for anonymous pages and ignore direct-IO. The driver
issue is going to need some serious thinking, and doing it for anonymous
pages only may be enough for many things. Especially if anonymous pages
_prefer_ the high-memory pages.

Oh, and copied-on-write pages count as anonymous, I assume you did that
already (ie when you allocate a new page and copy the old contents into
it, you might as well consider the new page to be anonymous, even though
it gets its initial data from a potentially non-anonymous page).

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
