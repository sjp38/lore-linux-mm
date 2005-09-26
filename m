Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8QLm254012103
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 17:48:02 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8QLnMrJ543872
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 15:49:22 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8QLnLUL004576
	for <linux-mm@kvack.org>; Mon, 26 Sep 2005 15:49:21 -0600
Message-ID: <43386CDF.5070905@austin.ibm.com>
Date: Mon, 26 Sep 2005 16:49:19 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/9] fragmentation avoidance
References: <4338537E.8070603@austin.ibm.com>
In-Reply-To: <4338537E.8070603@austin.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Joel Schopp <jschopp@austin.ibm.com>, lhms <lhms-devel@lists.sourceforge.net>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> well.  I believe the patches are now ready for inclusion in -mm, and after
> wider testing inclusion in the mainline kernel.
> 
> The patch set consists of 9 patches that can be merged in 4 separate 
> blocks,
> with the only dependency being that the lower numbered patches are merged
> first.  All are against 2.6.13.
> Patch 1 defines the allocation flags and adds them to the allocator calls.
> Patch 2 defines some new structures and the macros used to access them.
> Patch 3-8 implement the fully functional fragmentation avoidance.
> Patch 9 is trivial but useful for memory hotplug remove.
> ---
> Patch 10 -- not ready for merging -- extends fragmentation avoidance to the
> percpu allocator.  This patch works on 2.6.13-rc1 but only with NUMA off on
> 2.6.13; I am having a great deal of trouble tracking down why, help 
> would be
> appreciated.  I include the patch for review and test purposes as I plan to
> submit it for merging after resolving the NUMA issues.

It was pointed out that I did not make it clear that I would like the 9 patches
in this series merged into -mm.  They are ready to go.

Patch 10 is just a bonus patch you can ignore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
