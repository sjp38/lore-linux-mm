Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBH8gs8F025357
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 03:42:54 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBH8gsqZ258722
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 03:42:54 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBH8gsmu031701
	for <linux-mm@kvack.org>; Fri, 17 Dec 2004 03:42:54 -0500
Subject: Re: [patch] CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041217061150.GF12049@wotan.suse.de>
References: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com>
	 <20041217061150.GF12049@wotan.suse.de>
Content-Type: text/plain
Message-Id: <1103272960.13614.3084.camel@localhost>
Mime-Version: 1.0
Date: Fri, 17 Dec 2004 00:42:40 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm <linux-mm@kvack.org>, Andy Wihitcroft <apw@shadowen.org>, Matthew E Tolentino <matthew.e.tolentino@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-12-16 at 22:11, Andi Kleen wrote:
> On Thu, Dec 16, 2004 at 04:44:20PM -0800, Dave Hansen wrote:
> > This reduces another one of the dependencies that struct page's
> > definition has on any arch-specific header files.  Currently,
> > only x86_64 uses this, so it's the only architecture that needed
> > to be modified.
> 
> That's for page_flags_t, right?

Yep.

> I think it could be dropped right now and just use unsigned long for
> flags again. 

That's fine with me (and a much simpler patch).

> Since the objrmap work the saved 4 bytes in struct page are wasted in padding 
> and I haven't found a way to use them for real space saving again
> because all other members are 8 byte or paired 4 byte.

Well, since you asked... :)

In a newer revision of the nonlinear code, Andy Whitcroft has decided to
store part of the page_to_pfn() translation directly in page->flags,
right next to the zone information.  This is a bit of a squeeze on
32-bit arches, but on the 64-bit ones, there's plenty of room since
nobody is using the upper 32 bits at all.

I didn't realize that x86_64 had a 32-bit type there, so we probably
would have suggested turning it into a 64-bit one eventually.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
