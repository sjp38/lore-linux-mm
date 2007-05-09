Date: Wed, 9 May 2007 12:54:16 +0000
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: pcmcia ioctl removal
Message-ID: <20070509125415.GA4720@ucw.cz>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501084623.GB14364@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070501084623.GB14364@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

Hi!

> >  pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch
> 
> ...
> 
> > Dominik is busy.  Will probably re-review and send these direct to Linus.
> 
> The patch above is the removal of cardmgr support.  While I'd love to
> see this cruft gone it definitively needs maintainer judgement on whether
> they time has come that no one relies on cardmgr anymore.

I remember needing cardmgr few months ago on sa-1100 arm system. I'm
not sure this is obsolete-enough to kill.

							Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
