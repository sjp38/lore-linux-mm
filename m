Date: Sat, 5 Jul 2008 01:13:22 +0200
From: Olivier Galibert <galibert@pobox.com>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704231322.GA4410@dspnet.fr.eu.org>
References: <20080703.162120.206258339.davem@davemloft.net> <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1215182557.10393.808.camel@pmac.infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Hannes Reinecke <hare@suse.de>, Takashi Iwai <tiwai@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2008 at 03:42:37PM +0100, David Woodhouse wrote:
> It doesn't yet; that patch is in linux-next. The firmware is shipped as
> part of the kernel source tree, and you currently need to run 'make
> firmware_install' to put it in /lib/firmware, although we're looking at
> making that easier because apparently having to run 'make
> firmware_install' is too hard...

Won't that break multiple kernel installs on any binary packaging
system that cares about file collisions?  Multiple kernel rpms
providing the same /lib/firmware files would break things wouldn't
they ?

  OG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
