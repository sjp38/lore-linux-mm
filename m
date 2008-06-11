Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5BKUBsc020356
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 16:30:11 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5BKYPTR139388
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:34:25 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5BKYODK019737
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:34:25 -0600
Subject: Re: [v4][PATCH 2/2] fix large pages in pagemap
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080611131108.61389481.akpm@linux-foundation.org>
References: <20080611180228.12987026@kernel>
	 <20080611180230.7459973B@kernel>
	 <20080611123724.3a79ea61.akpm@linux-foundation.org>
	 <1213213980.20045.116.camel@calx>
	 <20080611131108.61389481.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 11 Jun 2008 13:34:22 -0700
Message-Id: <1213216462.20475.36.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matt Mackall <mpm@selenic.com>, hans.rosenfeld@amd.com, linux-mm@kvack.org, hugh@veritas.com, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-06-11 at 13:11 -0700, Andrew Morton wrote:
> Really?  There already a couple of pmd_huge() tests in mm/memory.c and
> Rik's access_process_vm-device-memory-infrastructure.patch adds
> another one.

We're not supposed to ever hit the one in follow_page() because there
are:

                if (is_vm_hugetlb_page(vma)) {
                        i = follow_hugetlb_page(mm, vma, pages, vmas,
                                                &start, &len, i, write);
                        continue;
                }

checks before them like in get_user_pages();

The other mm/memory.c call is under alloc_vm_area(), and that's
supposedly only used on kernel addresses.  I don't think we even have
Linux pagetables for kernel addresses on ppc.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
