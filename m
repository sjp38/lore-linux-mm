Date: Wed, 9 May 2007 09:00:03 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: pcmcia ioctl removal
In-Reply-To: <20070509125415.GA4720@ucw.cz>
Message-ID: <Pine.LNX.4.64.0705090858240.4919@localhost.localdomain>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <20070501084623.GB14364@infradead.org> <20070509125415.GA4720@ucw.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Pavel Machek wrote:

> Hi!
>
> > >  pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch
> >
> > ...
> >
> > > Dominik is busy.  Will probably re-review and send these direct to Linus.
> >
> > The patch above is the removal of cardmgr support.  While I'd love
> > to see this cruft gone it definitively needs maintainer judgement
> > on whether they time has come that no one relies on cardmgr
> > anymore.
>
> I remember needing cardmgr few months ago on sa-1100 arm system. I'm
> not sure this is obsolete-enough to kill.

in that case, someone really should update
feature-removal-schedule.txt, which currently reads:

What:   PCMCIA control ioctl (needed for pcmcia-cs [cardmgr, cardctl])
When:   November 2005
...

rday
-- 
========================================================================
Robert P. J. Day Linux Consulting, Training and Annoying Kernel
Pedantry Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
