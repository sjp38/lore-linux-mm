Date: Mon, 30 Apr 2001 15:53:52 +0200 (MET DST)
From: Szabolcs Szakacsits <szaka@f-secure.com>
Subject: anti-deadlock logic (was Re: RFC: Bouncebuffer fixes)
In-Reply-To: <20010429161012.F11395@athlon.random>
Message-ID: <Pine.LNX.4.30.0104301525240.16238-100000@fs131-224.f-secure.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Arjan van de Ven <arjanv@redhat.com>, linux-mm@kvack.org, alan@lxorguk.ukuu.org.uk, Linus Torvalds <torvalds@transmeta.com>, "Jeff V. Merkey" <jmerkey@vger.timpanogas.org>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Apr 2001, Andrea Arcangeli wrote:

> Note that the fact GFP_BUFFER fails or succeed is absolutely not
> interesting and unrelated to the anti-deadlock logic.

May I ask what's the anti-deadlock logic? Because it does not work [see
all kind of MM related hangs, livelocks on lkml]. As for 2.4.4 only
GFP_ATOMIC, kswapd, reclaimd, mtdblockd and OOM killed process
allocations can return NULL [from __alloc_pages()], all others will loop
until the requested free page(s) become available.

	Szaka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
