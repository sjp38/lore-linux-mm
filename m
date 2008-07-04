Message-ID: <486E3622.1000900@suse.de>
Date: Fri, 04 Jul 2008 16:39:30 +0200
From: Hannes Reinecke <hare@suse.de>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	<20080703173040.GB30506@mit.edu>	<1215111362.10393.651.camel@pmac.infradead.org>	<20080703.162120.206258339.davem@davemloft.net>	<486D6DDB.4010205@infradead.org>	<87ej6armez.fsf@basil.nowhere.org>	<1215177044.10393.743.camel@pmac.infradead.org>	<486E2260.5050503@garzik.org>	<1215178035.10393.763.camel@pmac.infradead.org>	<20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de>
In-Reply-To: <s5habgxloct.wl%tiwai@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Takashi Iwai <tiwai@suse.de>
Cc: Theodore Tso <tytso@mit.edu>, David Woodhouse <dwmw2@infradead.org>, Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Takashi,

Takashi Iwai wrote:
> At Fri, 4 Jul 2008 10:10:14 -0400,
> Theodore Tso wrote:
>> On Fri, Jul 04, 2008 at 02:27:15PM +0100, David Woodhouse wrote:
>>> That's the way it has been for a _long_ time anyway, for any modern
>>> driver which uses request_firmware(). The whole point about modules is
>>> _modularity_. Yes, that means that sometimes they depend on _other_
>>> modules, or on firmware. 
>>>
>>> The scripts which handle that kind of thing have handled inter-module
>>> dependencies, and MODULE_FIRMWARE(), for a long time now.
>> FYI, at least Ubuntu Hardy's initramfs does not seem to deal with
>> firmware for modules correctly.  
> 
> Neither SUSE's mkinitrd.
> (Hannes, please correct if I'm wrong...)
> 
???

Firmware loading is just a matter of copying the file at the correct
location (ie /lib/firmware) and with the name the fw loader expects.
mkinitrd should do it correctly.
But I wasn't aware that the tg3 has external firmware, so I doubt
we have any rpm for it.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke		      zSeries & Storage
hare@suse.de			      +49 911 74053 688
SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Markus Rex, HRB 16746 (AG Nurnberg)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
