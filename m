Date: Mon, 25 Sep 2000 18:05:00 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: the new VMt
Message-ID: <20000925180500.B26719@athlon.random>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu> <20000925164249.G2615@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925164249.G2615@redhat.com>; from sct@redhat.com on Mon, Sep 25, 2000 at 04:42:49PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 04:42:49PM +0100, Stephen C. Tweedie wrote:
> Progress is made, clean pages are discarded and dirty ones queued for

How can you make progress if there isn't swap avaiable and all the
freeable page/buffer cache is just been freed? The deadlock happens
in OOM condition (not when we can make progress).

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
