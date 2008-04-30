Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UKmhWe029316
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 16:48:43 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UKmgZX191956
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 14:48:42 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3UKmgDM009401
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 14:48:42 -0600
Date: Wed, 30 Apr 2008 13:48:41 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
Message-ID: <20080430204841.GD6903@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015431.462123000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:19 +1000], npiggin@suse.de wrote:
> Add an hugepagesz=... option similar to IA64, PPC etc. to x86-64.
> 
> This finally allows to select GB pages for hugetlbfs in x86 now
> that all the infrastructure is in place.

Another more basic question ... how do we plan on making these hugepages
available to applications. Obviously, an administrator can mount
hugetlbfs with pagesize=1G or whatever and then users (with appropriate
permissions) can mmap() files created therein. But what about
SHM_HUGETLB? It uses a private internal mount of hugetlbfs, which I
don't believe I saw a patch to add a pagesize= parameter for.

So SHM_HUGETLB will (for now) always get the "default" hugepagesize,
right, which should be the same as the legacy size? Given that an
architecture may support several hugepage sizes, I have't been able to
come up with a good way to extend shmget() to specify the preferred
hugepagesize when SHM_HUGETLB is specified. I think for libhugetlbfs
purposes, we will probably add another environment variable to control
that...

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
