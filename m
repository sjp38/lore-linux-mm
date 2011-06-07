Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 22CCD6B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 17:29:53 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p57LIFRH007520
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 15:18:15 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p57LTnNN083742
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 15:29:50 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p57FTn0K029474
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 09:29:49 -0600
Subject: Re: [PATCH] REPOST: Dirty page tracking for physical system
 migration
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <AC1B83CE65082B4DBDDB681ED2F6B2EF1ACDA0@EXHQ.corp.stratus.com>
References: <AC1B83CE65082B4DBDDB681ED2F6B2EF1ACDA0@EXHQ.corp.stratus.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Jun 2011 14:29:44 -0700
Message-ID: <1307482184.3048.111.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paradis, James" <James.Paradis@stratus.com>
Cc: linux-mm@kvack.org

On Tue, 2011-06-07 at 16:54 -0400, Paradis, James wrote:
>  /* Set of bits not changed in pte_modify */
>  #define _PAGE_CHG_MASK (PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |
> \
> -                        _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY)
> +                        _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY
> |
> \
> +                        _PAGE_SOFTDIRTY)
>  #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
>  
>  #define _PAGE_CACHE_MASK       (_PAGE_PCD | _PAGE_PWT)

This is still line-wrapped, corrupt, and unapplyable. :(

You might want to check out Documentation/email-clients.txt

> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -30,3 +30,5 @@ obj-$(CONFIG_NUMA_EMU)                +=
> numa_emulation.o
>  obj-$(CONFIG_HAVE_MEMBLOCK)            += memblock.o
>  
>  obj-$(CONFIG_MEMTEST)          += memtest.o
> +
> +obj-$(CONFIG_TRACK_DIRTY_PAGES)        += track.o 

I think you missed track.c in this patch.  Maybe you forgot to add -N to
your diff.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
