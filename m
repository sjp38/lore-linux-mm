Message-ID: <486F596C.8050109@firstfloor.org>
Date: Sat, 05 Jul 2008 13:22:20 +0200
From: Andi Kleen <andi@firstfloor.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de> <20080705105317.GA44773@dspnet.fr.eu.org>
In-Reply-To: <20080705105317.GA44773@dspnet.fr.eu.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Olivier Galibert <galibert@pobox.com>, Takashi Iwai <tiwai@suse.de>, David Woodhouse <dwmw2@infradead.org>, Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Olivier Galibert wrote:
> On Sat, Jul 05, 2008 at 09:41:56AM +0200, Takashi Iwai wrote:
>> Yes, it will, if the firmware blobs are packed into the kernel
>> package.  In a long term, we can put firmware files into a separate, 
>> architecture independent noarch package, though.  This will save the
>> total package size, too.
> 
> That could be interestingly hard, actually.  Right now the kernel
> package is one of these packages designed so that multiple versions
> can be installed together.  When the version of one of the firmwares
> changes, the firmware package will have to be updated.  But will it
> keep the previous version?  If it doesn't, the possibly still
> installed older kernels won't work anymore.  If it does, it will
> accumulate a lot of files over time...

Many distribution have some way for separate kernel module packages.
It's essentially the same problem so it should be already solved
in some way. Also there are already drivers who rely on separate
firmware so they already should have this problem (and hopefully
a solution). Of course these existing solutions might not be good
enough. And a lot of people ignored them because they didn't use
these external packages and drivers with those requirements.

I agree with you that doing this for more drivers will be a further complication
and the rationale why this complication is needed for drivers like tg3 or
e100 so far didn't  sound very convincing to me. If I read it correctly it
was "some other drivers do it this way so let's complicate everybody and
put them on the same level". Perhaps I'm dense, but I failed
to see the convincing reason in that.

On the other hand for my personal use it this change should be
transparent, at least as long as "make firmware_install"
will be integrated into "make modules_install" and put the files somewhere where
they don't conflict with other versions.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
