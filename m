Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3R3WjHX028974
	for <linux-mm@kvack.org>; Sat, 26 Apr 2008 23:32:45 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3R3WjQb221034
	for <linux-mm@kvack.org>; Sat, 26 Apr 2008 21:32:45 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3R3WifP013554
	for <linux-mm@kvack.org>; Sat, 26 Apr 2008 21:32:45 -0600
Date: Sat, 26 Apr 2008 20:32:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 14/18] hugetlb: printk cleanup
Message-ID: <20080427033242.GA12129@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015431.134811000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015431.134811000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:16 +1000], npiggin@suse.de wrote:
> - Reword sentence to clarify meaning with multiple options
> - Add support for using GB prefixes for the page size
> - Add extra printk to delayed > MAX_ORDER allocation code
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
>  mm/hugetlb.c |   21 +++++++++++++++++----
>  1 file changed, 17 insertions(+), 4 deletions(-)
> 
> Index: linux-2.6/mm/hugetlb.c
> ===================================================================
> --- linux-2.6.orig/mm/hugetlb.c
> +++ linux-2.6/mm/hugetlb.c
> @@ -612,15 +612,28 @@ static void __init hugetlb_init_hstates(
>  	}
>  }
> 
> +static __init char *memfmt(char *buf, unsigned long n)

Nit: this function is the only one where __init preceds the return type?

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
