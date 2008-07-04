Date: Thu, 3 Jul 2008 21:47:05 -0400
From: Theodore Tso <tytso@mit.edu>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080704014705.GM30506@mit.edu>
References: <1215093175.10393.567.camel@pmac.infradead.org> <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <20080704001855.GJ30506@mit.edu> <486D783B.6040904@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <486D783B.6040904@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 04, 2008 at 02:09:15AM +0100, David Woodhouse wrote:
> But there's no need to do it _now_. It can wait until the basic stuff is  
> in Linus' tree and it can automatically derive from that. There's no  
> particular rush, is there?

The only rush if the main agenda is to extirpate all firmware from the
mainline kernel sources.  I don't think we can start the timer for
doing that until the firmware tarball is created and it starts being
used as the default way of delivering firmware for what you call
"legacy" drivers.  If there's no particular rush to finally rm the
firmware for trivers such as tg3 from the source tree (and I
personally don't think there should be any rush), or any rush to
change the default for CONFIG_FIRMWARE_IN_KERNEL to "no", then I don't
see any rush in creating the firmware tarball.  

If *you* think there is a rush in making CONFIG_FIRMWARE_IN_KERNEL
default to "no", then you might want to decide to create the firmware
tarball sooner, and get distro's everywhere to start using it, and to
get everyone to understand that they should start including it in
their systems.  (Remember, not everyone uses the popular distributions
like Fedora, Debian, Ubuntu, Open SuSE, etc.)

But heck, that's up to you.  :-)

>> and for a while (read: at least 9-18 months) we can distribute firmware
> > both in the kernel source tarball as well as separately
>
> That makes a certain amount of sense.

Glad we agree.

>> in the licensing-religion-firmware tarball. 
>
> Please don't be gratuitously offensive, Ted. It's not polite, and it's  
> not a particularly good debating technique either. I expect better from 
> you.

Well, I think it's offensive to break users who have happily been
using drivers that have been including firmware for a long, long, LONG
time, and I expected better of you.

So there.  :-)

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
