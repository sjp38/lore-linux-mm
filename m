Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
Date: Fri, 4 Nov 2005 17:37:42 -0800
Message-ID: <01EF044AAEE12F4BAAD955CB75064943051354C4@scsmsx401.amr.corp.intel.com>
From: "Seth, Rohit" <rohit.seth@intel.com>
Sender: owner-linux-mm@kvack.org
From: Nick Piggin Friday, November 04, 2005 4:08 PM
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Andi Kleen <ak@suse.de>
Cc: Gregory Maxwell <gmaxwell@gmail.com>, Andy Nelson <andy@thermo.lanl.gov>, mingo@elte.hu, akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, torvalds@osdl.org
List-ID: <linux-mm.kvack.org>


>These are essentially the same problems that the frag patches face as
>well.

>> None of this is very attractive.
>> 

>Though it is simple and I expect it should actually do a really good
>job for the non-kernel-intensive HPC group, and the highly tuned
>database group.

Not sure how applications seamlessly can use the proposed hugetlb zone
based on hugetlbfs.  Depending on the programming language, it might
actually need changes in libs/tools etc.

As far as databases are concerned, I think they mostly already grab vast
chunks of memory to be used as hugepages (particularly for big mem
systems)which is a separate list of pages.  And actually are also glad
that kernel never looks at them for any other purpose.

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
