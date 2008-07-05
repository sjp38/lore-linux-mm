Date: Sat, 5 Jul 2008 16:44:45 +0200
From: Olivier Galibert <galibert@pobox.com>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080705144445.GA17319@dspnet.fr.eu.org>
References: <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de> <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org> <20080705120221.GC44773@dspnet.fr.eu.org> <486F6494.8020108@firstfloor.org> <1215260166.10393.816.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1215260166.10393.816.camel@pmac.infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Takashi Iwai <tiwai@suse.de>, Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 05, 2008 at 01:16:06PM +0100, David Woodhouse wrote:
> It almost never happens that you have kernel versions which _need_
> different firmware installed. In almost all cases, the older driver will
> continue to work just fine with the newer firmware (and its bug-fixes).

I'm not sure which planet you're from, but it's one without ipw2200
chips in it.  And in any case, the file names change.


> The ABI between driver and firmware rarely changes in such a fashion
> that you have to update the driver in lock-step -- and even on the
> occasions that it does, it's not hard to simply change the name of the
> "new-style" firmware so that it doesn't stomp on the old one (Think of
> it like an soname).

Ah, I see, you just didn't read the thread you're replying to.  Let's
do it again one more time.

The question is, how do you sanely distribute the kernel-tree
generated firmware in a binary distribution, knowing that you want to
be able to have multiple working kernels installed simultaneously?

Solution 1: in the kernel package
 -> You get file conflicts on the firmware files that do not change
    between kernel versions

Solution 2: in a package by itself
 -> You either break compatibility with kernel versions that happened
    before a firmware change, or you accumulate tons of files over
    time.  The accumulated form gets hard to create from source.

Solution 3: in the kernel package or in a kernel-specific package, but
  the files are in a kernel version-specific directory
  (/lib/firmware/`uname -r`, /lib/modules/`uname -r`/firmware)
 -> Incompatible with current userspace

Solution 4: in one package per firmware file, with appropriate
  dependencies on the kernel package
 -> A number of kernel package maintainers just took a hit on you


Any other solution you can see?

  OG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
