Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k03Lf830021528
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 16:41:08 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k03LdpZM205508
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 14:39:51 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k03Lf8Mx022677
	for <linux-mm@kvack.org>; Tue, 3 Jan 2006 14:41:08 -0700
Message-ID: <43BAEF69.3020006@austin.ibm.com>
Date: Tue, 03 Jan 2006 15:40:57 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: [Patch] New zone ZONE_EASY_RECLAIM take 4. (Change PageHighMem())[8/8]
References: <20051220173217.1B18.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051220173217.1B18.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> This patch is change PageHighMem()'s definition for i386.
> Easy reclaim zone is treated like highmem on i386.

This doesn't look like an i386 file, it looks like you are changing it 
for all architectures that have HIGHMEM (do any other archs use 
highmeme?). This may be fine, just wanted you to be aware.

> 
> This is new patch at take 4.
> 
> Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
> 
> Index: zone_reclaim/include/linux/page-flags.h
> ===================================================================
> --- zone_reclaim.orig/include/linux/page-flags.h	2005-12-15 21:01:09.000000000 +0900
> +++ zone_reclaim/include/linux/page-flags.h	2005-12-15 21:24:07.000000000 +0900
> @@ -265,7 +265,7 @@ extern void __mod_page_state_offset(unsi
>  #define TestSetPageSlab(page)	test_and_set_bit(PG_slab, &(page)->flags)
>  
>  #ifdef CONFIG_HIGHMEM
> -#define PageHighMem(page)	is_highmem(page_zone(page))
> +#define PageHighMem(page)	is_higher_zone(page_zone(page))
>  #else
>  #define PageHighMem(page)	0 /* needed to optimize away at compile time */
>  #endif
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
