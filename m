Date: Mon, 9 Oct 2000 18:39:45 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <Pine.LNX.4.10.10010091435420.1438-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0010091839240.1562-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Jim Gettys <jg@pa.dec.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 9 Oct 2000, Linus Torvalds wrote:
> On Mon, 9 Oct 2000, Alan Cox wrote:
> > > consumption. X certainly knows on behalf of which connection resources
> > > are created; the OS could then transfer this back to the appropriate client
> > > (at least when on machine).
> > 
> > Definitely - and this is present in some non Unix OS's. We do pass credentials
> > across AF_UNIX sockets so the mechanism is notionally there to provide the 
> > credentials to X, just not to use them
> 
> The problem is that there is no way to keep track of them afterwards.
> 
> So the process that gave X the bitmap dies. What now? Are we going to
> depend on X un-counting the resources?
> 
> I'd prefer just X having a higher "mm nice level" or something.

Which it has, because:

1) CAP_RAW_IO
2) p->euid == 0

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
