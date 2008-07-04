Message-ID: <486E2E5B.8030801@garzik.org>
Date: Fri, 04 Jul 2008 10:06:19 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	<20080703173040.GB30506@mit.edu>	<1215111362.10393.651.camel@pmac.infradead.org>	<20080703.162120.206258339.davem@davemloft.net>	<486D6DDB.4010205@infradead.org>	<87ej6armez.fsf@basil.nowhere.org>	<1215177044.10393.743.camel@pmac.infradead.org>	<486E2260.5050503@garzik.org>	<1215178035.10393.763.camel@pmac.infradead.org>	<486E2818.1060003@garzik.org> <20080704142753.27848ff8@lxorguk.ukuu.org.uk>
In-Reply-To: <20080704142753.27848ff8@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: David Woodhouse <dwmw2@infradead.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> Why is it so difficult to see the value of KEEPING STUFF WORKING AS IT 
>> WORKS TODAY?
> 
> Sure Jeff. Lets delete libata, that caused all sorts of problems when it
> was being added. We could freeze on linux 1.2.13-lmp, that was a good
> release - why break it ?
> 
> There are good sound reasons for having a firmware tree, the fact tg3 is
> a bit of dinosaur in this area doesn't make it wrong.

I never said it was wrong.

I have said repeatedly that separating out the firmware is the right 
thing to do.

But...  you don't need to force the switchover.  You don't need to break 
things that work today, in order to accomplish this.

It is quite feasible to do both -- keep things working as they work 
today, _and_ add /lib/firmware infrastructure.  Then we can work to 
switch distros over to the new system.

Further, it is not only feasible, but the only "nice" thing to do to 
other developers, users, and distros:  permit them to choose when to 
stop the decades-old practice of building firmware into some drivers.

Perform the transition in a sane, staged, planned manner that doesn't 
result in tons of non-working drivers.  I have already provided many 
real world examples where people, doing the same things they do today, 
will be greeted with non-working drivers upon the next boot.  Without 
any warning or error messages along the way, hinting that something 
might be wrong.

Or, for the cheap seats:

	End goal: good

	dwmw2's current path:  very easy to produce dead driver

	Needed resolution:  first step should /not/ produce regressions;

			    current evidence demonstrates current
			    implementation is full of regressions
			    that seasoned kernel hackers are hitting

It /is/ possible to add /lib/firmware gadgetry while avoiding the 
obvious low-hanging-fruit regressions and flag-day conversions that have 
been pointed out here.

Just say no to flag-day changes like this.  It is possible for each 
distro and boot image script to have their own flag-day.  Give them that 
choice.

	Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
