Subject: Re: the new VMt
Date: Mon, 25 Sep 2000 17:51:49 +0100 (BST)
In-Reply-To: <20000925164249.G2615@redhat.com> from "Stephen C. Tweedie" at Sep 25, 2000 04:42:49 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13dbTq-0005Gg-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > 2 active processes, no swap
> > 
> > #1					#2
> > kmalloc 32K				kmalloc 16K
> > OK					OK
> > kmalloc 16K				kmalloc 32K
> > block					block
> > 
> 
> ... and we get two wakeup_kswapd()s.  kswapd has PF_MEMALLOC and so is
> able to eat memory which processes #1 and #2 are not allowed to touch.

'no swap'

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
