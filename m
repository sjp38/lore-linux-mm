Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA00478
	for <linux-mm@kvack.org>; Fri, 26 Jun 1998 10:31:59 -0400
Subject: Re: glibc and kernel update
References: <Pine.LNX.3.96.980626063318.2529B-100000@mirkwood.dummy.home>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 26 Jun 1998 09:43:57 -0500
In-Reply-To: Rik van Riel's message of Fri, 26 Jun 1998 06:34:41 +0200 (CEST)
Message-ID: <m1iulofck2.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "RR" == Rik van Riel <H.H.vanRiel@phys.uu.nl> writes:

RR> On 25 Jun 1998, Eric W. Biederman wrote:
RR> I still haven't resolved the problems between glibc, the
RR> 2.1 kernel series and pppd :(
>> 
RR> Now I got a new idea: Since most of the kernel interfaces
RR> go through glibc, does this mean that I have to get the
RR> glibc source and recompile the whole thing in order to get
RR> working ppp with a 2.1 kernel?
>> 
>> Just what problem are you having?

RR> Pppd dies with "This kernel doesn't support PPP", while it
RR> most certainly _does_. I traced it back to a socket operation
RR> which isn't exported properly through glibc...

>> I just got 2.3.5 to compile with glibc, but I haven't had a chance to
>> test it yet..

RR> It compiles perfectly. It just doesn't run ;(

I just did a second test.
pppd-2.3.5 with glibc-2.0.6 on kernel-2.1.101 (with a few patches)
pppd works here.

The only thing I can imagine is do your /usr/include/linux & /usr/include/asm
point to ``safe'' kernel headers or the real thing.  Mine point to the real thing.

Eric
