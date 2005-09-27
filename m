Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8R0NGfJ005988
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 20:23:16 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8R0OPrJ187524
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 18:24:25 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8R0OOeg003883
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 18:24:25 -0600
Subject: Re: [PATCH 1/9] add defrag flags
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <21024267-29C3-4657-9C45-17D186EAD808@mac.com>
References: <4338537E.8070603@austin.ibm.com>
	 <43385412.5080506@austin.ibm.com>
	 <21024267-29C3-4657-9C45-17D186EAD808@mac.com>
Content-Type: text/plain
Date: Mon, 26 Sep 2005 17:24:08 -0700
Message-Id: <1127780648.10315.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kyle Moffett <mrmacman_g4@mac.com>
Cc: Joel Schopp <jschopp@austin.ibm.com>, Andrew Morton <akpm@osdl.org>, lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2005-09-26 at 20:16 -0400, Kyle Moffett wrote:
> On Sep 26, 2005, at 16:03:30, Joel Schopp wrote:
> > The flags are:
> > __GFP_USER, which corresponds to easily reclaimable pages
> > __GFP_KERNRCLM, which corresponds to userspace pages
> 
> Uhh, call me crazy, but don't those flags look a little backwards to  
> you?  Maybe it's just me, but wouldn't it make sense to expect  
> __GFP_USER to be a userspace allocation and __GFP_KERNRCLM to be an  
> easily reclaimable kernel page?

I think Joel simply made an error in his description.

__GFP_KERNRCLM corresponds to pages which are kernel-allocated, but have
some chance of being reclaimed at some point.  Basically, they're things
that will get freed back under memory pressure.  This can be direct, as
with the dcache and its slab shrinker, or more indirect as for control
structures like buffer_heads that get reclaimed after _other_ things are
freed.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
