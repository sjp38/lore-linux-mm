Date: Mon, 25 Sep 2000 20:04:54 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: the new VMt
Message-ID: <20000925200454.A14728@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0009251714480.9122-100000@elte.hu> <E13da01-00057k-00@the-village.bc.nu> <20000925164249.G2615@redhat.com> <20000925105247.A13935@hq.fsmlabs.com> <20000925191829.A14612@pcep-jamie.cern.ch> <20000925115139.A14999@hq.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925115139.A14999@hq.fsmlabs.com>; from yodaiken@fsmlabs.com on Mon, Sep 25, 2000 at 11:51:39AM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

yodaiken@fsmlabs.com wrote:
> > yodaiken@fsmlabs.com wrote:
> > >    walk = out;
> > >         while(nfds > 0) {
> > >                 poll_table *tmp = (poll_table *) __get_free_page(GFP_KERNEL);
> > >                 if (!tmp) {
> > 
> > Shouldn't this be GFP_USER?  (Which would also conveniently fix the
> > problem Victor's pointing out...)
> 
> It should probably be GFP_ATOMIC, if I understand the mm right. 

Definitely not.  GFP_ATOMIC is reserved for things that really can't
swap or schedule right now.  Use GFP_ATOMIC indiscriminately and you'll
have to increase the number of atomic-allocatable pages.

> The algorithm for requesting a collection of reources and freeing all
> of them on failure is simple, fast, and robust.

Allocation is just as fast with GFP_KERNEL/USER, just less likely to
fail and less likely to break something else that really needs
GFP_ATOMIC allocations.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
