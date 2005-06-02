Message-ID: <058801c567c2$6a412de0$0f01a8c0@max>
From: "Richard Purdie" <rpurdie@rpsys.net>
References: <20050516130048.6f6947c1.akpm@osdl.org> <20050516210655.E634@flint.arm.linux.org.uk> <030401c55a6e$34e67cb0$0f01a8c0@max> <20050516163900.6daedc40.akpm@osdl.org> <20050602220213.D3468@flint.arm.linux.org.uk>
Subject: Re: 2.6.12-rc4-mm2
Date: Thu, 2 Jun 2005 23:28:30 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>, Andrew Morton <akpm@osdl.org>
Cc: Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King:
>> > After some investigation, the guilty patch is:
>> > avoiding-mmap-fragmentation.patch
>> > (and hence) avoiding-mmap-fragmentation-tidy.patch
>
>> Wolfgang, we broke ARM.
>
> I'm not sure what happened with this, but there's someone reporting that
> -rc5-mm1 doesn't work.  Unfortunately, there's not a lot to go on:
>
> http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2005-May/029188.html
>
> Could be unrelated for all I know.

I found the above patch at fault, Wolfgang gave me a fix which I tested, 
confirmed working and that was going into future -mm releases last I heard. 
I've not had a chance to test -rc5 onwards myself yet due to the Nokia 
whirlwind but I doubt its the above problem.

I have heard comment that recent arm kernels on collie (sa1100) fail to boot 
for unknown reasons. The collie maintainer was looking into it - I only have 
pxa hardware to test with myself (which was working as of the last -rc4-mm 
release).

I'll update with the results of -rc5 on the pxa once I've tested it.

Cheers,

Richard 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
