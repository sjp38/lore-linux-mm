Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UKd6JK010452
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 16:39:06 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UKd6ca177642
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 14:39:06 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m412d51t020541
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 20:39:06 -0600
Message-ID: <4818D928.6070408@linux.vnet.ibm.com>
Date: Wed, 30 Apr 2008 15:40:08 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 17/18] x86: add hugepagesz option on 64-bit
References: <20080423015302.745723000@nick.local0.net> <20080423015431.462123000@nick.local0.net> <20080430193416.GE8597@us.ibm.com>
In-Reply-To: <20080430193416.GE8597@us.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

Nishanth Aravamudan wrote:
<snip>
> power would presumably make this 3, to support 64K,16M,16G (and 2, if
> basepage size is 64K).
>
> Another issue for power, though, is that there are local variables in
> arch/powerpc/hugetlbpage.c that depend on the hugepage size in use (and
> since there is only one, they're global). We really want those variables
> to be per-hstate, though, right? The three I see are mmu_huge_psize,
> HPAGE_SHIFT and hugepte_shift. For HPAGE_SHIFT, I think we could just
> switch them over to huge_page_shift(h) given an hstate, but we would
> need to make sure an hstate is available/obtainable at each point? Jon,
> do you have any insight here? I want to make sure struct hstate is
>   
So far I have used the page size or other lookup functions to determine
the hstate
and then use the hstate to get the information I need from it.  For
private functions
I have been passing the hstate around so that it doesn't have to be
looked up each
time.

The only other item of note for power is the huge_pgtable_cache for each
huge page size
that is built based on the value of hugepte_shift.

> future-proofed for other architectures than x86_64...
>
> We probably want to see how converting powerpc looks, then get IA64,
> sparc64 and sh on-board?
>
> Thanks,
> Nish
>
> --
>   
Jon


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
