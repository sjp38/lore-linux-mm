Date: Mon, 9 Oct 2000 14:38:10 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
In-Reply-To: <E13ikTP-0002sT-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.10.10010091435420.1438-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jim Gettys <jg@pa.dec.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Mon, 9 Oct 2000, Alan Cox wrote:
> > consumption. X certainly knows on behalf of which connection resources
> > are created; the OS could then transfer this back to the appropriate client
> > (at least when on machine).
> 
> Definitely - and this is present in some non Unix OS's. We do pass credentials
> across AF_UNIX sockets so the mechanism is notionally there to provide the 
> credentials to X, just not to use them

The problem is that there is no way to keep track of them afterwards.

So the process that gave X the bitmap dies. What now? Are we going to
depend on X un-counting the resources?

I'd prefer just X having a higher "mm nice level" or something.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
