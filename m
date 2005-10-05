Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95GAHhO023357
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:10:17 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95GD0fK433004
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:13:00 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j95GD055028427
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:13:00 -0600
Subject: Re: [PATCH] i386: nid_zone_sizes_init() update
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20051005083515.4305.16399.sendpatchset@cherry.local>
References: <20051005083515.4305.16399.sendpatchset@cherry.local>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 09:12:54 -0700
Message-Id: <1128528774.26009.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 17:35 +0900, Magnus Damm wrote:
> Broken out nid_zone_sizes_init() change from i386 NUMA emulation code.
...
> -static inline unsigned long  nid_size_pages(int nid)
> -{
> -	return node_end_pfn[nid] - node_start_pfn[nid];
> -}
> -static inline int nid_starts_in_highmem(int nid)
> -{
> -	return node_start_pfn[nid] >= max_low_pfn;
> -}

Hey, I liked those helpers!

When I suggested that you make your patches apply on top of the existing
-mhp stuff, I didn't just mean that they should _apply_, they should
probably mesh a little bit better.  For instance, it would be very
helpful to use those 'static inlines', or make a couple new ones if you
need them.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
