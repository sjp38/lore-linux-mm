Date: Mon, 9 Oct 2000 14:40:23 -0700 (PDT)
From: jg@pa.dec.com (Jim Gettys)
Message-Id: <200010092140.OAA08826@pachyderm.pa.dec.com>
In-Reply-To: <E13ikTP-0002sT-00@the-village.bc.nu>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Mime-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jim Gettys <jg@pa.dec.com>, Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, sct@redhat.com, keithp@keithp.com, dshr@arbitare.org
List-ID: <linux-mm.kvack.org>

> > Sounds like one needs in addition some mechanism for servers to "charge"
> clients for
> > consumption. X certainly knows on behalf of which connection resources
> > are created; the OS could then transfer this back to the appropriate client
> > (at least when on machine).
> 
> Definitely - and this is present in some non Unix OS's. We do pass credentials
> across AF_UNIX sockets so the mechanism is notionally there to provide the
> credentials to X, just not to use them

Stephen Tweedie, Dave Rosenthal, Keith Packard and myself had an extensive
discussion on similar ideas around process quantum scheduling (the X server
would like to be able to forward quantum to clients) as well at Usenix.
This is closely related, and needed to finally fully control interactive
feel in the face of "greedy" clients.

My memory is that it sounded like things could become very interesting
with such a facility, and might be ripe for 2.5.

Keith, Stephen, Dave, do you remember the details of our discussion?
			- Jim

--
Jim Gettys
Technology and Corporate Development
Compaq Computer Corporation
jg@pa.dec.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
