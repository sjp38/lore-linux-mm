Message-ID: <384F17BA.174B4C6D@mandrakesoft.com>
Date: Wed, 08 Dec 1999 21:45:14 -0500
From: Jeff Garzik <jgarzik@mandrakesoft.com>
MIME-Version: 1.0
Subject: Re: Getting big areas of memory, in 2.3.x?
References: <E11vtJW-0001YP-00@the-village.bc.nu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> 
> > What's the best way to get a large region of DMA'able memory for use
> > with framegrabbers and other greedy drivers?
> 
> Do you need physically linear memory >

Yes.  For the Meteor-II grabber I don't think so, but it looks like the
older (but mostly compatible) Corona needs it.


> > Per a thread on glx-dev, Andi Kleen mentions that the new 2.3.x MM stuff
> > still doesn't allieviate the need for bigphysarea and similar patches.
> 
> It helps, however the best answer is to use sane hardware which has scatter
> gather - eg the bttv frame grabbers grab 1Mb of memory or more, but they
> grab it as arbitary pages not a linear block.

That's the easy answer too :)

-- 
Jeff Garzik              | Just once, I wish we would encounter
Building 1024            | an alien menace that wasn't immune to
MandrakeSoft, Inc.       | bullets.   -- The Brigadier, "Dr. Who"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
