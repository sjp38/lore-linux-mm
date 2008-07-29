Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6TLjNmv007627
	for <linux-mm@kvack.org>; Tue, 29 Jul 2008 17:45:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6TLpNW9123312
	for <linux-mm@kvack.org>; Tue, 29 Jul 2008 15:51:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6TLpNxo024383
	for <linux-mm@kvack.org>; Tue, 29 Jul 2008 15:51:23 -0600
Subject: Re: sparcemem or discontig?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <488F5D5F.9010006@sciatl.com>
References: <488F5D5F.9010006@sciatl.com>
Content-Type: text/plain
Date: Tue, 29 Jul 2008 14:51:21 -0700
Message-Id: <1217368281.13228.72.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: linux-mm@kvack.org, msundius@sundius.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-07-29 at 11:11 -0700, C Michael Sundius wrote:
> 
> My understanding is that SPARCEMEM is the way of the future, and since
> I don't really have a NUMA machine, maybe sparcemem is more appropriate,
> yes? On the other hand I can't find much info about how it works or how
> to add support for it on an architecture that has here-to-fore not
> supported that option.
> 
> Is there anywhere that there is a paper or rfp that describes how the
> spacemem (or discontig) features work (and/or the differences between
> then)?

I think you're talking about sparsemem. :)

My opinion is that NUMA and DISCONTIG are too intertwined to be useful
apart from the other.  I use sparsemem on my non-NUMA 2 CPU laptop since
it has a 1GB hole.  It is *possible* to use DISCONTIG without NUMA, and
I'm sure people use it this way, but I just personally think it is a bit
of a pain.  

Basically, to add sparsemem support for an architecture, you need a
header like these:

dave@nimitz:~/lse/linux/2.5/linux-2.6.git$ find | grep sparse | xargs
grep -c '^.*$'
./include/asm-powerpc/sparsemem.h:32
./include/asm-x86/sparsemem.h:34
./include/asm-sh/sparsemem.h:16
./include/asm-mips/sparsemem.h:14
./include/asm-ia64/sparsemem.h:20
./include/asm-s390/sparsemem.h:18
./include/asm-arm/sparsemem.h:10

These are generally pretty darn small (the largest is 34 lines).  You
also need to tweak some things in your per-arch Kconfig.  ARM looks like
a pretty simple use of sparsemem.  You might want to start with what
they've done.  We tried really, really hard to make it easy to add to
new architectures.

Feel free to cc me and Andy (cc'd) on the patches that you come up with.
I'd be happy to sanity check them for you.  If *you* want to document
the process for the next guy, I'm sure we'd be able to find some spot in
Documentation/ so the next guy has an easier time. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
