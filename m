Date: Mon, 25 Sep 2000 18:39:47 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000925183947.K2615@redhat.com>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu> <20000925164249.G2615@redhat.com> <20000925180500.B26719@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925180500.B26719@athlon.random>; from andrea@suse.de on Mon, Sep 25, 2000 at 06:05:00PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 06:05:00PM +0200, Andrea Arcangeli wrote:
> On Mon, Sep 25, 2000 at 04:42:49PM +0100, Stephen C. Tweedie wrote:
> > Progress is made, clean pages are discarded and dirty ones queued for
> 
> How can you make progress if there isn't swap avaiable and all the
> freeable page/buffer cache is just been freed? The deadlock happens
> in OOM condition (not when we can make progress).

Agreed --- this assumes that all pinned, nonswappable pages are
subject to resource limiting to prevent them from exhausting the whole
of memory.  For things like page tables, that means we need
beancounter in place for us to be 100% safe.  For the no-swap case,
that requires an OOM killer.

The problem of avoiding filling memory with pinned pages is orthogonal
to the problem of managing the unpinned memory.  Both are obviously
required for a stable system.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
