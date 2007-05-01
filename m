Date: Tue, 1 May 2007 05:16:13 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: pcmcia ioctl removal
In-Reply-To: <20070501084623.GB14364@infradead.org>
Message-ID: <Pine.LNX.4.64.0705010514300.9162@localhost.localdomain>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <20070501084623.GB14364@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Christoph Hellwig wrote:

> >  pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch
>
> ...
>
> > Dominik is busy.  Will probably re-review and send these direct to Linus.
>
> The patch above is the removal of cardmgr support.  While I'd love
> to see this cruft gone it definitively needs maintainer judgement on
> whether they time has come that no one relies on cardmgr anymore.

since i was the one who submitted the original patch to remove that
stuff, let me make an observation.

when i submitted a patch to remove, for instance, the traffic shaper
since it's clearly obsolete, i was told -- in no uncertain terms --
that that couldn't be done since there had been no warning about its
impending removal.

fair enough, i can accept that.

on the other hand, the features removal file contains the following:

...
What:   PCMCIA control ioctl (needed for pcmcia-cs [cardmgr, cardctl])
When:   November 2005
...

in other words, the PCMCIA ioctl feature *has* been listed as obsolete
for quite some time, and is already a *year and a half* overdue for
removal.

in short, it's annoying to take the position that stuff can't be
deleted without warning, then turn around and be reluctant to remove
stuff for which *more than ample warning* has already been given.
doing that just makes a joke of the features removal file, and makes
you wonder what its purpose is in the first place.

a little consistency would be nice here, don't you think?

rday
-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
