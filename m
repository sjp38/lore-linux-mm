Date: Sun, 30 Apr 2000 17:39:48 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH] 2.3.99-pre6-7 VM rebalanced
Message-ID: <20000430173948.A26377@fred.muc.de>
References: <Pine.LNX.4.10.10004300357400.4270-100000@iq.rulez.org> <E12lvU3-0008Ki-00@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E12lvU3-0008Ki-00@the-village.bc.nu>; from Alan Cox on Sun, Apr 30, 2000 at 05:27:51PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Sasi Peter <sape@iq.rulez.org>, riel@nl.linux.org, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Sun, Apr 30, 2000 at 05:27:51PM +0200, Alan Cox wrote:
> > The problem with this is that even if the kernel is in .99 pre-release
> > state for several weeks _nothing_ has been changed in it about the RAID
> > stuff still, so a lot of people using 2.2 + raid 0.90 patch (eg. RedHat
> > users) _cannot_ change to and try 2.3.99, because their partitions would
> > not mount.
> > 
> > It seems to me, that if we are talking about widening the testbase for
> > 2.3.99, this is the most important item on Alan's todo list.
> 
> In some ways it probably is. Almost every production site I would feed stuff
> to is using raid 0.90 and some of them are now using ext3 as well. 

Here I have similar problems with reiserfs (a lot of sites use it
already, upto reiserfs root).  So far the 2.3 port cannot read 2.2
file systems.

Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
