Date: Mon, 25 Sep 2000 19:49:53 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925194953.A29260@athlon.random>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl> <20000925014137.B6249@athlon.random> <20000925192148.A24362@home.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925192148.A24362@home.ds9a.nl>; from ahu@ds9a.nl on Mon, Sep 25, 2000 at 07:21:48PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 25, 2000 at 07:21:48PM +0200, bert hubert wrote:
> Ok, sorry. Kernel development is proceding at a furious pace and I sometimes
> lose track. 

No problem :).

> I seem to remember that people were impressed by classzone, but that the
> implementation was very non-trivial and hard to grok. One of the reasons

Yes. Classzone is certainly more complex.

> There is no such thing as 'under swap'. There are lots of loadpatterns that
> will generate different kinds of memory pressure. Just calling it 'under
> swap' gives entirely the wrong impression. 

Sorry for not being precise. I meant one of those load patterns.

> 'rivaling virtual memory' code. Energies spent on Rik's VM will yield far
> higher differential improvement. 

I've spent efforts on classzone as well, and since I think it's way superior
approch I'll at least port it on top of 2.4.0-test9 as soon as time
permits to generate some number.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
