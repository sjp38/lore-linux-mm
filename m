Date: Mon, 25 Sep 2000 18:01:31 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VM
Message-ID: <20000925180131.A26719@athlon.random>
References: <Pine.LNX.4.21.0009251511050.6224-100000@elte.hu> <E13dZX7-00055f-00@the-village.bc.nu> <20000925164044.F2615@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925164044.F2615@redhat.com>; from sct@redhat.com on Mon, Sep 25, 2000 at 04:40:44PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:40:44PM +0100, Stephen C. Tweedie wrote:
> Allowing GFP_ATOMIC to eat PF_MEMALLOC's last-chance pages is the
> wrong thing to do if we want to guarantee swapper progress under
> extreme load.

You're definitely right. We at least need the garantee of the memory to
allocate the bhs on top of the swap cache while we atttempt to swapout one page
(that path can't fail at the moment).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
