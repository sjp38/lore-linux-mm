Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0F56B0078
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 12:48:22 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e34.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0LHgCjI003476
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:42:12 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0LHm09o154324
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:48:03 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0LHlwMm026561
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 10:47:59 -0700
Subject: Re: [PATCH 11 of 30] add pmd mangling functions to x86
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <22367befceba0c312d15.1264054835@v2.random>
References: <patchbomb.1264054824@v2.random>
	 <22367befceba0c312d15.1264054835@v2.random>
Content-Type: text/plain
Date: Thu, 21 Jan 2010 09:47:56 -0800
Message-Id: <1264096076.32717.34496.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-01-21 at 07:20 +0100, Andrea Arcangeli wrote:
> @@ -351,7 +410,7 @@ static inline unsigned long pmd_page_vad
>   * Currently stuck as a macro due to indirect forward reference to
>   * linux/mmzone.h's __section_mem_map_addr() definition:
>   */
> -#define pmd_page(pmd)  pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT)
> +#define pmd_page(pmd)  pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)

Is there some new use of the high pmd bits or something?  I'm a bit
confused why this is getting modified.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
