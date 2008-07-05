Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <s5h4p746am3.wl%tiwai@suse.de>
References: <20080703.162120.206258339.davem@davemloft.net>
	 <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org>
	 <1215177044.10393.743.camel@pmac.infradead.org>
	 <486E2260.5050503@garzik.org>
	 <1215178035.10393.763.camel@pmac.infradead.org>
	 <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de>
	 <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org>
	 <20080704231322.GA4410@dspnet.fr.eu.org>  <s5h4p746am3.wl%tiwai@suse.de>
Content-Type: text/plain
Date: Sat, 05 Jul 2008 09:50:03 +0100
Message-Id: <1215247803.3189.45.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Takashi Iwai <tiwai@suse.de>
Cc: Olivier Galibert <galibert@pobox.com>, Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 2008-07-05 at 09:41 +0200, Takashi Iwai wrote:
> At Sat, 5 Jul 2008 01:13:22 +0200,
> Olivier Galibert wrote:
> > 
> > On Fri, Jul 04, 2008 at 03:42:37PM +0100, David Woodhouse wrote:
> > > It doesn't yet; that patch is in linux-next. The firmware is shipped as
> > > part of the kernel source tree, and you currently need to run 'make
> > > firmware_install' to put it in /lib/firmware, although we're looking at
> > > making that easier because apparently having to run 'make
> > > firmware_install' is too hard...
> > 
> > Won't that break multiple kernel installs on any binary packaging
> > system that cares about file collisions?  Multiple kernel rpms
> > providing the same /lib/firmware files would break things wouldn't
> > they ?
> 
> Yes, it will, if the firmware blobs are packed into the kernel
> package.  In a long term, we can put firmware files into a separate, 
> architecture independent noarch package, though.  This will save the
> total package size, too.

I'm not familiar with the SuSE kernel specfile, but it was a fairly
minor change to the Fedora kernel to do exactly that 'long term' thing.
The patch is in the fedora-kernel-list archives.

We have to do the same thing with exported headers, anyway -- those are
built from the kernel too, but again we need to have only one copy
installed or we'd get conflicts.

> But, right now, it's difficult because the installation and build of
> firmware files depend on the kernel config.  We'd need a make rule for
> installing the all firmware files for that purpose.

That's what 'make firmware_install' does. It's config- and arch-
independent, mostly because it was developed with distributors in mind. 

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
