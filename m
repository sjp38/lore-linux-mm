Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 17:53:45 +0100 (BST)
In-Reply-To: <Pine.LNX.4.21.0009251747190.9122-100000@elte.hu> from "Ingo Molnar" at Sep 25, 2000 06:02:18 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13dbVi-0005H4-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Frankly, how often do we allocate multi-order pages? I've just made quick
> statistics wrt. how allocation orders are distributed on a more or less
> typical system:

Enough that failures on this crashed older 2.2 kernels because the tcp code
ended up looping trying to get memory and the slab allocator couldnt get
a new multipage block. 

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
