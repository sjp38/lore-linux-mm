Date: Mon, 25 Sep 2000 16:51:51 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [patch] vmfixes-2.4.0-test9-B2 - fixing deadlocks
Message-ID: <20000925165151.I2615@redhat.com>
References: <20000924231240.D5571@athlon.random> <Pine.LNX.4.21.0009242310510.8705-100000@elte.hu> <20000924224303.C2615@redhat.com> <20000925001342.I5571@athlon.random> <20000925003650.A20748@home.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925003650.A20748@home.ds9a.nl>; from ahu@ds9a.nl on Mon, Sep 25, 2000 at 12:36:50AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 12:36:50AM +0200, bert hubert wrote:
> On Mon, Sep 25, 2000 at 12:13:42AM +0200, Andrea Arcangeli wrote:
> > On Sun, Sep 24, 2000 at 10:43:03PM +0100, Stephen C. Tweedie wrote:
> > > any form of serialisation on the quota file).  This feels like rather
> > > a lot of new and interesting deadlocks to be introducing so late in
> > > 2.4.  :-)
> 
> True. But they also appear to be found and solved at an impressive rate.
> These deadlocks are fatal and don't hide in corners, whereas the previous mm
> problems used to be very hard to spot and fix, there not being real
> showstoppers, except for abysmal performance. [1]

Sorry, but in this case you have got a lot more variables than you
seem to think.  The obvious lock is the ext2 superblock lock, but
there are side cases with quota and O_SYNC which are much less
commonly triggered.  That's not even starting to consider the other
dozens of filesystems in the kernel which have to be audited if we
change the locking requirements for GFP calls.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
