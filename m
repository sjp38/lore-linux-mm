Date: Mon, 25 Sep 2000 16:42:49 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000925164249.G2615@redhat.com>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E13da01-00057k-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Mon, Sep 25, 2000 at 04:16:56PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 04:16:56PM +0100, Alan Cox wrote:
> 
> Unless Im missing something here think about this case
> 
> 2 active processes, no swap
> 
> #1					#2
> kmalloc 32K				kmalloc 16K
> OK					OK
> kmalloc 16K				kmalloc 32K
> block					block
> 

... and we get two wakeup_kswapd()s.  kswapd has PF_MEMALLOC and so is
able to eat memory which processes #1 and #2 are not allowed to touch.
Progress is made, clean pages are discarded and dirty ones queued for
write, memory becomes free again and the world is a better place.

Or so goes the theory, at least.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
