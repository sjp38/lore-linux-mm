Date: Fri, 4 Jul 2008 10:36:34 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704143634.GC23215@mit.edu>
References: <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <20080704142403.GD7212@baikonur.stro.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080704142403.GD7212@baikonur.stro.at>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: maximilian attems <max@stro.at>
Cc: David Woodhouse <dwmw2@infradead.org>, Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2008 at 04:24:03PM +0200, maximilian attems wrote:
> yes i'd call them severly broken.
> as it is quite easy to pick up the modinfo firmware module output.
> 
> their trouble is that they sync initramfs-tools from Debian only
> once every 2 years or so.

Well, Takashi just mentioned that SuSE's mkinitrd may not handle
/lib/firmware correctly either....

> hpa is working to provide a lot of what is needed in klibc.
> it isn't yet there as it misses mdadm, lvm2 and cryptsetup support,
> but it is getting much better due to our Debian/Ubuntu exposure.
> we added several features to klibc and fixed bugs. similar to the
> early opensuse exposure which unfortunately got dropped.

I will definitely sign up to try this once there is lvm2 support.  :-)

         		       	     	      - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
