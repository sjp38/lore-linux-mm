Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3LKoYZC004101
	for <linux-mm@kvack.org>; Mon, 21 Apr 2008 16:50:34 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3LKoYkt215830
	for <linux-mm@kvack.org>; Mon, 21 Apr 2008 16:50:34 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3LKoYKJ013570
	for <linux-mm@kvack.org>; Mon, 21 Apr 2008 16:50:34 -0400
Subject: Re: [patch 01/17] hugetlb: modular state
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
In-Reply-To: <20080410171100.425293000@nick.local0.net>
References: <20080410170232.015351000@nick.local0.net>
	 <20080410171100.425293000@nick.local0.net>
Content-Type: text/plain
Date: Mon, 21 Apr 2008 15:51:24 -0500
Message-Id: <1208811084.11866.10.camel@skynet>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, andi@firstfloor.org, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-04-11 at 03:02 +1000, npiggin@suse.de wrote:

<snip>

> Index: linux-2.6/include/linux/hugetlb.h
> ===================================================================
> --- linux-2.6.orig/include/linux/hugetlb.h
> +++ linux-2.6/include/linux/hugetlb.h
> @@ -40,7 +40,7 @@ extern int sysctl_hugetlb_shm_group;
> 
>  /* arch callbacks */
> 
> -pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr);
> +pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, int sz);

<snip>

The sz here needs to be a long to handle sizes such as 16G on powerpc.

There are other places in hugetlb.c where the size also needs to be a
long, but this one affects the arch code too since it is public.

Jon
Tollefson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
