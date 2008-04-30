Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3UL1J79007654
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 17:01:19 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3UL19MW086870
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:01:10 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3UL16mr017449
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 15:01:09 -0600
Subject: Re: [patch 12/18] hugetlbfs: support larger than MAX_ORDER
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080423015430.965631000@nick.local0.net>
References: <20080423015302.745723000@nick.local0.net>
	 <20080423015430.965631000@nick.local0.net>
Content-Type: text/plain
Date: Wed, 30 Apr 2008 14:01:03 -0700
Message-Id: <1209589263.4461.35.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-04-23 at 11:53 +1000, npiggin@suse.de wrote:
> +static int __init alloc_bm_huge_page(struct hstate *h)

I was just reading one of Jon's patches, and saw this.  Could we expand
the '_bm_' to '_boot_'?  Or, maybe rename to bootmem_alloc_hpage()?
'bm' just doesn't seem to register in my teeny brain.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
