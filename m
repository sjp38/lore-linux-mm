Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2266B0044
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 12:59:24 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n0JHw6J2032676
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 10:58:06 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0JHxNTl218116
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 10:59:23 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0JHxMIg007189
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 10:59:22 -0700
Date: Mon, 19 Jan 2009 09:59:19 -0800
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
Message-ID: <20090119175919.GA7476@us.ibm.com>
References: <4973AEEC.70504@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4973AEEC.70504@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Roel Kluin <roel.kluin@gmail.com>
Cc: garyhade@us.ibm.com, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jan 18, 2009 at 11:36:28PM +0100, Roel Kluin wrote:
> get_nid_for_pfn() returns int
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> vi drivers/base/node.c +256
> static int get_nid_for_pfn(unsigned long pfn)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 43fa90b..f8f578a 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -303,7 +303,7 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
>  	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
>  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> -		unsigned int nid;
> +		int nid;
> 
>  		nid = get_nid_for_pfn(pfn);
>  		if (nid < 0)

My mistake.  Good catch.

Thanks,
Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
