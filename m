Received: from granada.iram.es (root@granada.iram.es [150.214.224.100])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA17797
	for <linux-mm@kvack.org>; Fri, 9 Apr 1999 05:32:17 -0400
Date: Fri, 9 Apr 1999 11:27:10 +0200 (METDST)
From: Gabriel Paubert <paubert@iram.es>
Subject: Re: [patch] arca-vm-2.2.5
In-Reply-To: <m1n20iwa8t.fsf@flinx.ccr.net>
Message-ID: <Pine.HPP.3.96.990409104632.13413S-100000@gra-ux1.iram.es>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Arvind Sankar <arvinds@MIT.EDU>, davem@redhat.com, mingo@chiara.csoma.elte.hu, sct@redhat.com, andrea@e-mind.com, cel@monkey.org, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On 9 Apr 1999, Eric W. Biederman wrote:

> AS> typo there, I guess. the >> should be an integer division. Since the divisor is
> AS> a constant power of 2, the compiler will optimize it into a shift.
> 
> Actually I believe:
> #define DIVISOR(x) (x  & ~((x >> 1) | ~(x >> 1)))
                           ^^^^^^^^^^^^^^^^^^^^^^^

interesting formula. Unless I'm wrong, set y=x>>1 and evaluate it again:

	~(y | ~y)

which should give zero on any binary machine. So I think you've come up
with a sophisticated way of generating an OOPS :-) at least on
architectures which don't silently and happily divide by zero. 

I've needed it quite often but I don't know of any short formula which
computes the log2 of an integer (whether rounded up or down does not
matter) with standard C operators. 

I've been looking for it quite carefully, and I don't even think that it
is possible: there is an example on how to do this in the HP-UX assembler
documentation, it takes 18 machine instructions (no loops, performing a
binary search) and it has been written by people who, as you would
expect, know very well the tricks of the architecture (cascaded
conditional nullification to perform branchless if then else: the then
branch is a shift, the else branch is an add).

Code size or time are not the problem here since it is a compile time
constant, but trying to find a simple C expression to approximate log2 is
probably futile (and not worth the effort in this case). 

	Gabriel. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
