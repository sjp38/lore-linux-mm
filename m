Message-ID: <390F188F.8D3C35E1@norran.net>
Date: Tue, 02 May 2000 20:03:59 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: kswapd @ 60-80% CPU during heavy HD i/o.
References: <Pine.LNX.4.21.0005021238430.10610-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Tue, 2 May 2000, Roger Larsson wrote:
> 
> > I have been playing with the idea to have a lru for each zone.
> > It should be trivial to do since page contains a pointer to zone.
> >
> > With this change you will shrink_mmap only check among relevant pages.
> > (the caller will need to call shrink_mmap for other zone if call failed)
> 
> That's a very bad idea.

Has it been tested?
I think the problem with searching for a DMA page among lots and lots
of normal and high pages might be worse...

> 
> In this case you can end up constantly cycling through the pages of
> one zone while the pages in another zone remain idle.

Yes you might. But concidering the possible no of pages in each zone,
it might not be that a bad idea.

You usually needs normal pages and there are more normal pages.
You rarely needs DMA pages but there are less.
=> recycle rate might be about the same...

Anyway I think it is up to the caller of shrink_mmap to be intelligent
about which zone it requests.

> 
> Local page replacement is worse than global page replacement and
> has always been...
> 
> regards,
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/               http://www.surriel.com/
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
