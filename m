Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3THRaop007427
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 13:27:36 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3THRaN1283774
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 13:27:36 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3THRaxx004713
	for <linux-mm@kvack.org>; Tue, 29 Apr 2008 13:27:36 -0400
Date: Tue, 29 Apr 2008 10:27:34 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 05/18] hugetlb: multiple hstates
Message-ID: <20080429172734.GE24967@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.162027000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015430.162027000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:07 +1000], npiggin@suse.de wrote:
> Add basic support for more than one hstate in hugetlbfs
> 
> - Convert hstates to an array
> - Add a first default entry covering the standard huge page size
> - Add functions for architectures to register new hstates
> - Add basic iterators over hstates
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  include/linux/hugetlb.h |   11 ++++
>  mm/hugetlb.c            |  112 +++++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 97 insertions(+), 26 deletions(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================

<snip>

> +/* Should be called on processing a hugepagesz=... option */
> +void __init huge_add_hstate(unsigned order)

For consistency's sake, can we call this hugetlb_add_hstate()?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
