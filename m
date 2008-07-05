Message-ID: <486F6494.8020108@firstfloor.org>
Date: Sat, 05 Jul 2008 14:09:56 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de> <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org> <20080705120221.GC44773@dspnet.fr.eu.org>
In-Reply-To: <20080705120221.GC44773@dspnet.fr.eu.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olivier Galibert <galibert@pobox.com>, Andi Kleen <andi@firstfloor.org>, Takashi Iwai <tiwai@suse.de>, David Woodhouse <dwmw2@infradead.org>, Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Olivier Galibert wrote:
> On Sat, Jul 05, 2008 at 01:22:20PM +0200, Andi Kleen wrote:
>> Many distribution have some way for separate kernel module packages.
>> It's essentially the same problem so it should be already solved
>> in some way.
> 
> Errr, no.  Modules go in /lib/modules/`uname -r`, so no conflict.

Well that's the only sane way to store the firmware anyways (otherwise
you could never keep kernel versions which need different firmware installed)

While the current code doesn't do that there have been proposals for that
and I assume/hope they will be acted on.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
