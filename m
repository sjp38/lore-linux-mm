Date: Mon, 25 Sep 2000 18:43:38 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000925184338.L2615@redhat.com>
References: <20000925164249.G2615@redhat.com> <E13dbTq-0005Gg-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E13dbTq-0005Gg-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Mon, Sep 25, 2000 at 05:51:49PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 05:51:49PM +0100, Alan Cox wrote:
> > > 2 active processes, no swap
> > > 
> > > #1					#2
> > > kmalloc 32K				kmalloc 16K
> > > OK					OK
> > > kmalloc 16K				kmalloc 32K
> > > block					block
> > > 
> > 
> > ... and we get two wakeup_kswapd()s.  kswapd has PF_MEMALLOC and so is
> > able to eat memory which processes #1 and #2 are not allowed to touch.
> 
> 'no swap'

kswapd is perfectly capable of evicting clean pages and triggering any
necessary writeback of dirty filesystem data at this point, even if
there is no swap.  If there is truly nothing kswapd can do to recover
here, then we are truly OOM.  Otherwise, kswapd should be able to free
the required memory, providing that the PF_MEMALLOC flag allows it to
eat into a reserved set of free pages which nobody else can allocate
once physical free pages gets below a certain threshold.

--Stephen 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
