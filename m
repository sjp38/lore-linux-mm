Message-ID: <486F7DB8.4070509@firstfloor.org>
Date: Sat, 05 Jul 2008 15:57:12 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <486E2260.5050503@garzik.org>	 <1215178035.10393.763.camel@pmac.infradead.org>	 <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de>	 <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org>	 <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de>	 <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org>	 <20080705120221.GC44773@dspnet.fr.eu.org> <486F6494.8020108@firstfloor.org>	 <1215260166.10393.816.camel@pmac.infradead.org>	 <486F67B7.9040304@firstfloor.org> <1215261779.10393.829.camel@pmac.infradead.org>
In-Reply-To: <1215261779.10393.829.camel@pmac.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Olivier Galibert <galibert@pobox.com>, Takashi Iwai <tiwai@suse.de>, Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
> On Sat, 2008-07-05 at 14:23 +0200, Andi Kleen wrote:
>> That's a lot of "should" and "in most cases" and "in a ideal world".
> 
> OK, let's phrase it differently:
> 
> It almost never happens, and it's trivial to handle it safely in the
> extremely rare cases that it does. 

Ok. I'm not sure how you got to your conclusion (I assume you did significant
research on this), but please make sure driver writers and reviewers
are aware of this new requirement.

>>  What happens when the new firmware is buggy for example and prevents
>> booting of the system?
> 
> If the firmware is required for booting the system, 

initramfs is only required for drivers required to
mount the root file system. But there's a lot more to completely booting
a system than just mounting root.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
