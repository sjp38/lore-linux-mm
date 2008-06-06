Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m56GA41v004790
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 12:10:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m56GA4S7170122
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 10:10:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m56GA3I3026031
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 10:10:03 -0600
Subject: Re: [patch 14/21] x86: add hugepagesz option on 64-bit
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1212595315.7567.41.camel@nimitz.home.sr71.net>
References: <20080603095956.781009952@amd.local0.net>
	 <20080603100939.967775671@amd.local0.net>
	 <1212515282.8505.19.camel@nimitz.home.sr71.net>
	 <20080603182413.GJ20824@one.firstfloor.org>
	 <1212519555.8505.33.camel@nimitz.home.sr71.net>
	 <20080603205752.GK20824@one.firstfloor.org>
	 <1212528479.7567.28.camel@nimitz.home.sr71.net>
	 <4845DC72.5080206@firstfloor.org>  <20080604010428.GB30863@wotan.suse.de>
	 <1212595315.7567.41.camel@nimitz.home.sr71.net>
Content-Type: text/plain
Date: Fri, 06 Jun 2008 09:09:59 -0700
Message-Id: <1212768599.7837.15.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, kniht@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-04 at 09:01 -0700, Dave Hansen wrote:
> On Wed, 2008-06-04 at 03:04 +0200, Nick Piggin wrote:
> > So I won't oppose this being tinkered with once it is in -mm or upstream.
> > So long as we try to make changes carefully. For example, there should
> > be no reason why we can't subsequently have a patch to register all
> > huge page sizes on boot, or if it is really important somebody might
> > write a patch to return the 1GB pages to the buddy allocator etc.
> > 
> > I'm basically just trying to follow the path of least resistance ;) So
> > I'm hoping that nobody is too upset with the current set of patches,
> > and from there I am very happy for people to submit incremental patches
> > to the user apis..
> 
> That sounds like a good plan to me.  Let's see how the patches look on
> top of what you have here.

I managed to implement most of this, but I'm not happy how it came out.
It's not quite functional, yet.

I don't think it is horribly worth doing unless it can simplify some of
what is there already, which this can't.  I basically ended up having to
write another little allocator to break down the large pages into
smaller ones.  That's sure to have bugs.

http://userweb.kernel.org/~daveh/boot-time-hugetlb-reservations.patch

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
