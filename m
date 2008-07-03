Date: Thu, 03 Jul 2008 16:21:20 -0700 (PDT)
Message-Id: <20080703.162120.206258339.davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Miller <davem@davemloft.net>
In-Reply-To: <1215111362.10393.651.camel@pmac.infradead.org>
References: <1215093175.10393.567.camel@pmac.infradead.org>
	<20080703173040.GB30506@mit.edu>
	<1215111362.10393.651.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 03 Jul 2008 19:56:02 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: dwmw2@infradead.org
Cc: tytso@mit.edu, jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> It's wrong to change the CONFIG_FIRMWARE_IN_KERNEL default to 'Y',
> because the _normal_ setting for that option _really_ should be 'N'.

On what basis?  From a "obviously works" basis, the default should be
'y'.

> What we're doing now is just cleaning up the older drivers which don't
> use request_firmware(), to conform to what is now common practice.

You say "conform" I say "break".

> In the meantime, it would be useful if Jeff would quit throwing his toys
> out of the pram on that issue and actually review the _code_ changes. In
> particular, are the reports correct that the device operates just fine
> without the TSO firmware loaded? Should we change the request_firmware()
> error path to just disable TSO and continue with the initialisation?

No!

The 5701 A0 firmware is necessary to load in order to work around
hardware and existing firmware bugs on those cards.  It's an issue of
basic functionality, not just optimizations.

5701 A0 tg3 chips cannot operate at all without the firmware being
present in the driver.

Therefore, if you can't load the firmware, the card is not going to
work.

> Less of the ad hominem, please. Especially when it's so misdirected.

No, it is properly directed, you are breaking the tree for users.

> Updating these drivers to remove large blobs of static unswappable data
> from the kernel, and having it provided from userspace on demand as
> modern Linux drivers do, is a perfectly sensible technical goal all on
> its own.

I disagree.

> And given the GPL's explicit provisions with regard to collective works
> there are also entirely reasonable, non-"fundamentalist" grounds for
> believing that it _may_ pose a licensing problem, and for wanting to err
> on the side of caution in that respect too.

So now the real truth is revealed.  You have no technical basis for
this stuff you are ramming down everyone's throats.

You want to choose a default based upon your legal agenda.

That explains all of the bullshit that is attached to your work, and
all of the bullshit arguments you make wrt. choosing defaults that
break things for users.

It's all about agendas rather than any real technical objectives.

If it was purely technical, you wouldn't be choosing defaults that
break things for users by default.  Jeff and I warned you about this
from day one, you did not listen, and now we have at least 10 reports
just today of people with broken networking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
