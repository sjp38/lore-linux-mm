Date: Mon, 9 Oct 2000 23:34:36 +0200
From: "Andi Kleen" <ak@suse.de>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009233436.A21846@gruyere.muc.suse.de>
References: <200010092121.OAA01924@pachyderm.pa.dec.com> <E13ikTP-0002sT-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E13ikTP-0002sT-00@the-village.bc.nu>; from alan@lxorguk.ukuu.org.uk on Mon, Oct 09, 2000 at 10:28:38PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Jim Gettys <jg@pa.dec.com>, Andi Kleen <ak@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, Byron Stanoszek <gandalf@winds.org>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Oct 09, 2000 at 10:28:38PM +0100, Alan Cox wrote:
> > Sounds like one needs in addition some mechanism for servers to "charge" clients for
> > consumption. X certainly knows on behalf of which connection resources
> > are created; the OS could then transfer this back to the appropriate client
> > (at least when on machine).
> 
> Definitely - and this is present in some non Unix OS's. We do pass credentials
> across AF_UNIX sockets so the mechanism is notionally there to provide the 
> credentials to X, just not to use them

X can get the pid using SO_PEERCRED for unix connections. 

When the oom killer maintains some kind of badness value in the task_struct
it would be possible to add a charge() systemcall that manipulates it.

int charge(pid_t pid, int memorytobecharged) 


-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
