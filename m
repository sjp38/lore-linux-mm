Date: Wed, 8 Dec 1999 23:22:05 -0600 (CST)
From: Oliver Xymoron <oxymoron@waste.org>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <384F17BA.174B4C6D@mandrakesoft.com>
Message-ID: <Pine.LNX.4.10.9912082311040.29662-100000@waste.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Dec 1999, Jeff Garzik wrote:

> Alan Cox wrote:
> > 
> > > What's the best way to get a large region of DMA'able memory for use
> > > with framegrabbers and other greedy drivers?
> > 
> > Do you need physically linear memory >
> 
> Yes.  For the Meteor-II grabber I don't think so, but it looks like the
> older (but mostly compatible) Corona needs it.

Most PCI DMA controllers can send you an end of transfer interrupt, at
which point you can hand it the next contiguous segment to transfer to -
software scatter-gather. Note that the number of segments (fragments)  
could very well be far fewer than the number of pages, meaning the
overhead could be pretty minimal, providing the latency doesn't kill you.

If the card has an NT driver, it almost certainly can be made to do this,
as NT has no support for allocating large physically contiguous memory
from drivers and pretty much forces this model.

--
 "Love the dolphins," she advised him. "Write by W.A.S.T.E.." 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
