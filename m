Date: Mon, 25 Sep 2000 20:48:06 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: the new VMt
Message-ID: <20000925204806.A16619@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu> <20000925164249.G2615@redhat.com> <20000925105247.A13935@hq.fsmlabs.com> <20000925191829.A14612@pcep-jamie.cern.ch> <20000925115139.A14999@hq.fsmlabs.com> <20000925200454.A14728@pcep-jamie.cern.ch> <20000925121315.A15966@hq.fsmlabs.com> <20000925192453.R2615@redhat.com> <20000925123456.A16612@hq.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925123456.A16612@hq.fsmlabs.com>; from yodaiken@fsmlabs.com on Mon, Sep 25, 2000 at 12:34:56PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

yodaiken@fsmlabs.com wrote:
> > Or go the beancounter route: process 1 asks "can I pin 20 pages", gets
> > told "yes", and goes allocating them, blocking as necessary until it
> 
> So you have a "pre-allocation allocator"?  Leads to interesting and
> hard to detect bugs with old code that does not pre-allocate or with
> code that incorrectly pre-allocates or that blocks on something
> unrelated

I agree with Victor.  Relying on code that calls gfp to do the correct
accounting in advance, to avoid deadlocks, is not at all robust.  Even
the best programmers will have off by one errors in that, and the rest
of us will blindly write code that works all the time, except for the
really obscure case when it fails.

Ideally do both: see if you can allocate in advance, then try it,
but be prepared to back off and return ENOMEM if that fails.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
