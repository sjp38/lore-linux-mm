Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Date: Mon, 9 Oct 2000 22:28:38 +0100 (BST)
In-Reply-To: <200010092121.OAA01924@pachyderm.pa.dec.com> from "Jim Gettys" at Oct 09, 2000 02:21:05 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E13ikTP-0002sT-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jim Gettys <jg@pa.dec.com>
Cc: Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Sounds like one needs in addition some mechanism for servers to "charge" clients for
> consumption. X certainly knows on behalf of which connection resources
> are created; the OS could then transfer this back to the appropriate client
> (at least when on machine).

Definitely - and this is present in some non Unix OS's. We do pass credentials
across AF_UNIX sockets so the mechanism is notionally there to provide the 
credentials to X, just not to use them
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
