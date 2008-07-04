Date: Thu, 3 Jul 2008 19:42:12 -0700 (PDT)
From: david@lang.hm
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
In-Reply-To: <486D6DDB.4010205@infradead.org>
Message-ID: <alpine.DEB.1.10.0807031938260.7820@asgard.lang.hm>
References: <1215093175.10393.567.camel@pmac.infradead.org> <20080703173040.GB30506@mit.edu> <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <486D6DDB.4010205@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: David Miller <davem@davemloft.net>, tytso@mit.edu, jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jul 2008, David Woodhouse wrote:

> David Miller wrote:
>> From: David Woodhouse <dwmw2@infradead.org>
>> Date: Thu, 03 Jul 2008 19:56:02 +0100
>> 
>>> It's wrong to change the CONFIG_FIRMWARE_IN_KERNEL default to 'Y',
>>> because the _normal_ setting for that option _really_ should be 'N'.
>> 
>> On what basis?  From a "obviously works" basis, the default should be
>> 'y'.
>
> I already changed it to 'y'.
>
>>> What we're doing now is just cleaning up the older drivers which don't
>>> use request_firmware(), to conform to what is now common practice.
>> 
>> You say "conform" I say "break".
>
> You mean...
> 	"What we're doing now is just cleaning up the older drivers
> 	 which don't use request_firmware(), to break to what is now
> 	 common practice."
> ?
>
> Doesn't really scan, does it?
>
> Common practice in modern Linux drivers is to use request_firmware(). I'm 
> just going through and fixing up the older ones to do that too.
>
> (After making it possible to build that firmware _into_ the kernel so that we 
> aren't forcing people to use an initrd where they didn't before, of course.)

has this taken place yet? (and if so, what kernel version first included 
this fix)

>> If it was purely technical, you wouldn't be choosing defaults that
>> break things for users by default.
>
> Actually, the beauty of Linux is that we _can_ change things where a minor 
> short-term inconvenience leads to a better situation in the long term.

but doing so should not be a easy and quick decision, and it needs to be 
made very clear exactly what breakage is going to take place and why 
(along with the explination of why the breakage couldn't be avoided)

>> Jeff and I warned you about this from day one, you did not listen, and
>> now we have at least 10 reports just today of people with broken
>> networking.
>
> Out of interest... of those, what proportion would be 'fixed' if they'd just 
> paid attention when running 'make oldconfig', which is now addressed because 
> I've changed the FIRMWARE_IN_KERNEL default to 'y'?
>
> And how many would be 'fixed' if someone had given me a straight answer when 
> I asked about the TSO firmware, and that failure path no longer aborted the 
> driver initialisation but instead just fell back to non-TSO?
>
> I'll look at making the requirement for 'make firmware_install' more obvious, 
> or even making it happen automatically as part of 'modules_install'.

I won't mind this as long as I can get a working kernel without doing make 
firmware_install or make modules_install (I almost never use modules, my 
laptop is one of the few exceptions, and even there it's mostly becouse of 
the intel wireless driver needing userspace for firmware)

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
