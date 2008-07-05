Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20080705144445.GA17319@dspnet.fr.eu.org>
References: <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de>
	 <1215182557.10393.808.camel@pmac.infradead.org>
	 <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de>
	 <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org>
	 <20080705120221.GC44773@dspnet.fr.eu.org> <486F6494.8020108@firstfloor.org>
	 <1215260166.10393.816.camel@pmac.infradead.org>
	 <20080705144445.GA17319@dspnet.fr.eu.org>
Content-Type: text/plain
Date: Sat, 05 Jul 2008 16:10:32 +0100
Message-Id: <1215270632.10393.864.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olivier Galibert <galibert@pobox.com>
Cc: Andi Kleen <andi@firstfloor.org>, Takashi Iwai <tiwai@suse.de>, Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 2008-07-05 at 16:44 +0200, Olivier Galibert wrote:
> On Sat, Jul 05, 2008 at 01:16:06PM +0100, David Woodhouse wrote:
> > It almost never happens that you have kernel versions which _need_
> > different firmware installed. In almost all cases, the older driver will
> > continue to work just fine with the newer firmware (and its bug-fixes).
> 
> I'm not sure which planet you're from, but it's one without ipw2200
> chips in it.  And in any case, the file names change.

I was speaking of the firmware which is currently in-kernel. ipw2200 is
a recent driver and uses request_firmware() already, so isn't affected
at all when I update other, older drivers. As such, it's not
particularly relevant to this discussion.

The drivers which we're updating to use request_firmware() have _not_
changed their firmware very often at all -- and even _less_ frequently
have they done so in an incompatible fashion.

> > The ABI between driver and firmware rarely changes in such a fashion
> > that you have to update the driver in lock-step -- and even on the
> > occasions that it does, it's not hard to simply change the name of the
> > "new-style" firmware so that it doesn't stomp on the old one (Think of
> > it like an soname).
> 
> Ah, I see, you just didn't read the thread you're replying to.  Let's
> do it again one more time.
> 
> The question is, how do you sanely distribute the kernel-tree
> generated firmware in a binary distribution, knowing that you want to
> be able to have multiple working kernels installed simultaneously?

 <...>

> Solution 2: in a package by itself

Probably this one. That package can be seeded from a git repo which is
automatically derived from the contents of the firmware/ directory in
Linus' tree, and can add the other firmware blobs which are available in
various places -- the ones that the owners won't let us include in the
kernel tree due to the GPL, but _will_ allow us to distribute in a
separate firmware repository.

>  -> You either break compatibility with kernel versions that happened
>     before a firmware change, or you accumulate tons of files over
>     time.  The accumulated form gets hard to create from source.

On the rare occasions that a firmware changes incompatibly, you'd want
to keep both old and new versions in the firmware tree for a reasonable
period of time. But since that doesn't happen very often, it isn't a
particularly difficult issue to handle. I strongly believe that you are
overestimating the scale of the problem -- and it would only be a
problem for the person maintaining the firmware repository anyway. I'm
perfectly content to do that job.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
