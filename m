Date: Mon, 25 Sep 2000 12:31:38 -0500 (CDT)
From: Oliver Xymoron <oxymoron@waste.org>
Subject: Re: the new VMt
In-Reply-To: <E13dbhk-0005J0-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.10.10009251227350.19220-100000@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Alexander Viro <viro@math.psu.edu>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Sep 2000, Alan Cox wrote:

> > > > Stupidity has no limits...
> > > 
> > > Unfortunately its frequently wired into the hardware to save a few cents on
> > > scatter gather logic.
> > 
> > Since when hardware folks became exempt from the rule above? 128K is
> > almost tolerable, there were requests for 64 _mega_bytes...
> 
> Most cheap ass PCI hardware is built on the basis you can do linear 4Mb 
> allocations. There is a reason for this. You can do that 4Mb allocation on
> NT or Windows 9x

Sure about that? It's been a while, but I seem to recall NT enforcing a
scatter-gather framework on all drivers because it only gave them virtual
allocations. For the cheaper cards, the s-g was done by software issuing
single span requests to the card.

--
 "Love the dolphins," she advised him. "Write by W.A.S.T.E.." 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
