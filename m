Date: Tue, 17 Aug 1999 14:40:50 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <Pine.LNX.4.10.9908162331400.1048-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.10.9908171439340.414-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, Linus Torvalds wrote:

>pages only may be enough for many things. Especially if anonymous pages
>_prefer_ the high-memory pages.

Yes shm/vmalloc/anonymous memory always prefer the high-memory pages.

>Oh, and copied-on-write pages count as anonymous, I assume you did that
>already (ie when you allocate a new page and copy the old contents into
>it, you might as well consider the new page to be anonymous, even though
>it gets its initial data from a potentially non-anonymous page).

Yes, the copy-on-write always prefer the bigmem pages for the allocation.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
