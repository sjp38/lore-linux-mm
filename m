Date: Mon, 25 Sep 2000 13:22:40 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: the new VMt
In-Reply-To: <20000925180500.B26719@athlon.random>
Message-ID: <Pine.LNX.4.21.0009251321360.14614-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Andrea Arcangeli wrote:
> On Mon, Sep 25, 2000 at 04:42:49PM +0100, Stephen C. Tweedie wrote:
> > Progress is made, clean pages are discarded and dirty ones queued for
> 
> How can you make progress if there isn't swap avaiable and all the
> freeable page/buffer cache is just been freed? The deadlock happens
> in OOM condition (not when we can make progress).

This is exactly why integrating the OOM killer is on
my TODO list.

The important difference between the new VM and the
old one is that we can't fail while we are not OOM,
whereas the old allocator could break down even when
we still had enough swap free....

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
