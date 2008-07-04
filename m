Message-ID: <486E2260.5050503@garzik.org>
Date: Fri, 04 Jul 2008 09:15:12 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	 <20080703173040.GB30506@mit.edu>	 <1215111362.10393.651.camel@pmac.infradead.org>	 <20080703.162120.206258339.davem@davemloft.net>	 <486D6DDB.4010205@infradead.org>  <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org>
In-Reply-To: <1215177044.10393.743.camel@pmac.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
> On Fri, 2008-07-04 at 12:09 +0200, Andi Kleen wrote:
>> David Woodhouse <dwmw2@infradead.org> writes:
>>> I'll look at making the requirement for 'make firmware_install' more
>>> obvious, or even making it happen automatically as part of
>>> 'modules_install'.
>> Perhaps I didn't pay enough attention, but how are "only 
>> boot bzImage without initrd or modules" setups supposed to work now
>> for those drivers? My testing setup relies on that heavily.
> 
> That will continue to work just fine.
> 
>> Will the firmware automatically end up in initramfs and be included
>> in the bzImage and loaded at the right point?
> 
> No, not even in the initramfs. It's built _right_ into the static kernel
> image, and request_firmware() finds it there without even having to call
> out to userspace at all.
> http://git.infradead.org/users/dwmw2/firmware-2.6.git?a=commitdiff;h=81d4e79a

However, there is still a broken element to the system:  the firmware no 
longer rides along in the module's .ko file.  That introduces new 
problems for any user and script that copies modules around.

The compiled-in firmware should be in the same place where it was before 
your changes -- in the driver's kernel module.

So, yes, there should not be regressions for non-module users.  Let's 
now solve the regression problem for the other half of the world...

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
