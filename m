Message-ID: <390CB8C1.E2C440FD@reiser.to>
Date: Sun, 30 Apr 2000 15:50:41 -0700
From: Hans Reiser <hans@reiser.to>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.3.99-pre6-7 VM rebalanced
References: <Pine.LNX.4.10.10004300357400.4270-100000@iq.rulez.org> <E12lvU3-0008Ki-00@the-village.bc.nu> <20000430173948.A26377@fred.muc.de>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Sasi Peter <sape@iq.rulez.org>, riel@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, "Vladimir V. Saveliev" <vs@namesys.botik.ru>
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> 
> On Sun, Apr 30, 2000 at 05:27:51PM +0200, Alan Cox wrote:
> > > The problem with this is that even if the kernel is in .99 pre-release
> > > state for several weeks _nothing_ has been changed in it about the RAID
> > > stuff still, so a lot of people using 2.2 + raid 0.90 patch (eg. RedHat
> > > users) _cannot_ change to and try 2.3.99, because their partitions would
> > > not mount.
> > >
> > > It seems to me, that if we are talking about widening the testbase for
> > > 2.3.99, this is the most important item on Alan's todo list.
> >
> > In some ways it probably is. Almost every production site I would feed stuff
> > to is using raid 0.90 and some of them are now using ext3 as well.
> 
> Here I have similar problems with reiserfs (a lot of sites use it
> already, upto reiserfs root).  So far the 2.3 port cannot read 2.2
> file systems.
> 
> Andi
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/

It can read 2.2 file systems, though once you mount it under 2.3 you can never
go back.  We are fixing that by having a -noconv mount option to prevent
conversion to the new format, but the code is not done yet.

Hans
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
