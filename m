Received: from alogconduit1ah.ccr.net (ccr@alogconduit1al.ccr.net [208.130.159.12])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA21877
	for <linux-mm@kvack.org>; Fri, 9 Apr 1999 13:35:17 -0400
Subject: Re: [patch] arca-vm-2.2.5
References: <Pine.HPP.3.96.990409104632.13413S-100000@gra-ux1.iram.es>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 09 Apr 1999 10:40:07 -0500
In-Reply-To: Gabriel Paubert's message of "Fri, 9 Apr 1999 11:27:10 +0200 (METDST)"
Message-ID: <m1lng1x0o8.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Gabriel Paubert <paubert@iram.es>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Arvind Sankar <arvinds@MIT.EDU>, davem@redhat.com, mingo@chiara.csoma.elte.hu, sct@redhat.com, andrea@e-mind.com, cel@monkey.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "GP" == Gabriel Paubert <paubert@iram.es> writes:

GP> On 9 Apr 1999, Eric W. Biederman wrote:

AS> typo there, I guess. the >> should be an integer division. Since the divisor is
AS> a constant power of 2, the compiler will optimize it into a shift.
>> 
>> Actually I believe:
>> #define DIVISOR(x) (x  & ~((x >> 1) | ~(x >> 1)))
GP>                            ^^^^^^^^^^^^^^^^^^^^^^^

GP> interesting formula. Unless I'm wrong, set y=x>>1 and evaluate it again:

GP> 	~(y | ~y)

GP> which should give zero on any binary machine.
Duh.  I forgot that the high bits got set.

GP> So I think you've come up
GP> with a sophisticated way of generating an OOPS :-) at least on
GP> architectures which don't silently and happily divide by zero. 

GP> I've needed it quite often but I don't know of any short formula which
GP> computes the log2 of an integer (whether rounded up or down does not
GP> matter) with standard C operators.

Well I wasn't trying for log2 but instead for truncating to the nearest
power of two, in a form that the compiler could compute, at compile time.

GP> I've been looking for it quite carefully, and I don't even think that it
GP> is possible: there is an example on how to do this in the HP-UX assembler
GP> documentation, it takes 18 machine instructions (no loops, performing a
GP> binary search) and it has been written by people who, as you would
GP> expect, know very well the tricks of the architecture (cascaded
GP> conditional nullification to perform branchless if then else: the then
GP> branch is a shift, the else branch is an add).

GP> Code size or time are not the problem here since it is a compile time
GP> constant, but trying to find a simple C expression to approximate log2 is
GP> probably futile (and not worth the effort in this case). 

True but it is fun :)

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
