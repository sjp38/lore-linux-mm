Date: Mon, 25 Sep 2000 17:41:38 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925174138.D25814@athlon.random>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E13da01-00057k-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Mon, Sep 25, 2000 at 04:16:56PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: mingo@elte.hu, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:16:56PM +0100, Alan Cox wrote:
> Unless Im missing something here think about this case
> 
> 2 active processes, no swap
> 
> #1					#2
> kmalloc 32K				kmalloc 16K
> OK					OK
> kmalloc 16K				kmalloc 32K
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> block					block

Yep, you're not missing anything. That was my complain about the fact
GFP_KERNEL not failing will obviously dealdock the kernel all over the place.

Ingo's point is that the underlined line won't ever happen in the first place
because of the resource accounting that will tell the upper layer that they
can't try to allocate anything, so they won't enter kmalloc at all. But he's
obviously not talking about 2.4.x. (and I'm not sure if that's the right
way to go in the general case but certainly it's the right way to go for
special cases like skbs with gigabit ethernet)

In 2.4.x GFP_KERNEL not failing is a deadlock as you said.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
