Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UKN5Ul013330
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 16:23:05 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UKN49v052862
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 14:23:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3UKN40t002775
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 14:23:04 -0600
Date: Wed, 30 Apr 2008 13:23:03 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080430202303.GB6903@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430193416.GE8597@us.ibm.com> <20080430195237.GE20451@one.firstfloor.org> <20080430200249.GA6903@us.ibm.com> <20080430201932.GH20451@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080430201932.GH20451@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 30.04.2008 [22:19:32 +0200], Andi Kleen wrote:
> > Then let's just merge whatever we'd like all the time? Why have review
> > at all?
> 
> Looking for bugs and problems is good, but to be honest many of your
> comments like more like "nit picking until it looks exactly what I
> would have written" and that is not the purpose of a review.

I'm sorry if that is how it appears. I promise you that is not the case.
You and Nick have tackled a hard problem and come up with an overall
good solution to it. I believe I said something similar in my reply to
the core (first) patch which abstracts the hstate in the first place. I
admittedly have not heard from Nick on any of my comments, so perhaps he
shares the same view that they are not productive. If so, I'll hold off
on any further review.

> > To quote Nick from a separate discussion on similar future-proofing:
> > 
> > "Let's really try to put some thought into new sysfs locations. Not just
> > will it work, but is it logical and will it work tomorrow..."
> 
> ABIs are different from code, they have to be more future proof
> because changing them has more impact (although that seems to be
> commonly ignored in sysfs)
> 
> > infrastructure we have in place, where it claims to be generic and
> 
> The hugetlbfs code actually doesn't claim that.

The hugetlb.c code is architecture independent and roughly generic (it
doesn't know a whole lot about the underlying architecture itself).
hstates are defined and used in this independent code -- hence my
perspective that we want to make sure it is flexible enough to handle
other architectures than x86_64, or at least easily extensible to them.

> > usable by architectures (as has been my impression from the discussions
> > so far -- that it is extensible to other architectures), I want to be
> > sure that is really the case.
> 
> It is with some future changes, but there is no need to do them for
> the initial merge, but they can be done as additional architectures
> are added.

Well, Nick was talking about adding the powerpc bits to his stack when
he submited for -mm, so these discussions should be happening now,
AFAICT.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
