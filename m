Message-ID: <486E2818.1060003@garzik.org>
Date: Fri, 04 Jul 2008 09:39:36 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	 <20080703173040.GB30506@mit.edu>	 <1215111362.10393.651.camel@pmac.infradead.org>	 <20080703.162120.206258339.davem@davemloft.net>	 <486D6DDB.4010205@infradead.org>  <87ej6armez.fsf@basil.nowhere.org>	 <1215177044.10393.743.camel@pmac.infradead.org>	 <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org>
In-Reply-To: <1215178035.10393.763.camel@pmac.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
> On Fri, 2008-07-04 at 09:15 -0400, Jeff Garzik wrote:
>> However, there is still a broken element to the system:  the firmware no 
>> longer rides along in the module's .ko file.  That introduces new 
>> problems for any user and script that copies modules around.
>>
>> The compiled-in firmware should be in the same place where it was before 
>> your changes -- in the driver's kernel module.
> 
> No, Jeff. That is neither new, nor a real problem. You're just
> posturing.
> 
> That's the way it has been for a _long_ time anyway, for any modern
> driver which uses request_firmware(). The whole point about modules is
> _modularity_. Yes, that means that sometimes they depend on _other_
> modules, or on firmware. 
> 
> The scripts which handle that kind of thing have handled inter-module
> dependencies, and MODULE_FIRMWARE(), for a long time now.

You have been told repeatedly that cp(1) and scp(1) are commonly used to 
transport the module David and I care about -- tg3.  It's been a single 
file module since birth, and people take advantage of that fact.

Therefore, logically, you have introduced additional dependencies and 
regressions into what was once a single-file copy.

If you wish to hand-wave away what developers and users do today as 
posturing, that's up to you...

How difficult is it to see that you must create a system that LET'S 
PEOPLE CHOOSE whether or not they like your stuff.

Why are you so hell-bent on removing choice?

Why is it so difficult to see the value of KEEPING STUFF WORKING AS IT 
WORKS TODAY?

Doing so (a) keeps developers happy, (b) GUARANTEES no regressions, and 
(c) in no way excludes /lib/firmware, moving firmware to userspace.

Sheesh.

Let developers, users, and distros endorse your plan on their own 
schedule.  Stop forcing your choices down our throats.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
