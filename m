Received: from flinx.ccr.net (ccr@alogconduit1ae.ccr.net [208.130.159.5])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA22546
	for <linux-mm@kvack.org>; Wed, 24 Mar 1999 06:43:01 -0500
Subject: Re: [Fwd: LINUX-MM]
References: <36F8974A.D4EB4BAD@imsid.uni-jena.de>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 24 Mar 1999 05:49:08 -0600
In-Reply-To: Matthias Arnold's message of "Wed, 24 Mar 1999 08:42:02 +0100"
Message-ID: <m1emmfxg3v.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "MA" == Matthias Arnold <Matthias.Arnold@edda.imsid.uni-jena.de> writes:

>> 
>> On Tue, 23 Mar 1999 10:49:11 EST, Kev <klmitch@MIT.EDU> said:
>> 
>> >> IIRC there's a slight bug in some of the newer kernels
>> >> where the swap cache isn't being freed when you exit
>> >> your program, but only later on when the system tries
>> >> to reclaim memory...
>> 
>> > I believe the problem lies in the fact that there is not enough
>> > SysV shared memory available.
>> 
>> It's nothing to do with SysV shared memory.
>> 
>> The behaviour is there, but the only impact on the normal user will be
>> that "free" lies a little.  No big deal: it just shows up as cache.  The
>> effect is only a matter of when we recover the memory, not whether we
>> recover it.

MA> Thanks to the community for dealing with my problems.Before we go  on to
MA> discuss this as bug or feature I emphasize
MA> that this memory effect is really disastrous for me.
MA> I hope that changing the kernel (as Rik told me) helps.
MA> Any suggestion is very welcome.

I missed the start of this, (I just monitor linux-mm),
what is the problem you have?

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
