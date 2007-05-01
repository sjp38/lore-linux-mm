Date: Tue, 1 May 2007 09:56:39 +0100
From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: pcmcia ioctl removal
Message-ID: <20070501085639.GA18233@flint.arm.linux.org.uk>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501084623.GB14364@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070501084623.GB14364@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, May 01, 2007 at 09:46:23AM +0100, Christoph Hellwig wrote:
> >  pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch
> 
> ...
> 
> > Dominik is busy.  Will probably re-review and send these direct to Linus.
> 
> The patch above is the removal of cardmgr support.  While I'd love to
> see this cruft gone it definitively needs maintainer judgement on whether
> they time has come that no one relies on cardmgr anymore.

And I still run and use a platform where the GUI issues cardmgr ioctls.
A recent kernel upgrade (from 2.6.9ish to something more recent) broke
the "eject" GUI button applet due to the fscking with the cardmgr ioctls,
and it thinks the wireless card is always plugged in (and therefore the
signal strength meter remains.)

With all the ioctls gone I'll probably loose the signal strength meter.

And no, I don't have the resources (read: code) to fix and rebuild
userspace since I didn't snarf them when the CVS server was alive a
few years back.

That's the problem with API changes - things always break.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
