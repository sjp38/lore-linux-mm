Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 17:57:15 +0100 (BST)
In-Reply-To: <Pine.GSO.4.21.0009251217020.16980-100000@weyl.math.psu.edu> from "Alexander Viro" at Sep 25, 2000 12:17:36 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13dbZ7-0005Hg-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > yep, i agree. I'm not sure what the biggest allocation is, some drivers
> > might use megabytes or contiguous RAM?
> 
> Stupidity has no limits...

Unfortunately its frequently wired into the hardware to save a few cents on
scatter gather logic.

We need 128K blocks for sound DMA buffers and most sound cards they need to
be linear (but not the newer ones thankfully). Some video capture hardware
needs 4Mb but that needs to use bootmem (in 2.2 they use bigmem hacks)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
