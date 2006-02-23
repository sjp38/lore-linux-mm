Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1NI6x19028186
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:07:00 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1NI6x82227100
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:06:59 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k1NI6x9e018756
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 13:06:59 -0500
Subject: Re: [RFC] memory-layout-free zones (for review) [2/3]  remvoe
	zone_start_pfn/spanned_pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060223175819.3fbb21fe.kamezawa.hiroyu@jp.fujitsu.com>
References: <20060223175819.3fbb21fe.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Thu, 23 Feb 2006 10:06:52 -0800
Message-Id: <1140718012.8697.63.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-02-23 at 17:58 +0900, KAMEZAWA Hiroyuki wrote:
> This patch removes zone_start_pfn/zone_spanned_pages from zone struct.
> (and also removes seqlock for zone resizing)
> 
> By this definion of zone will change
> from : a contiguous range of pages to be used in the same manner.
> to   : a group of pages to be used in the same manner.
> 
> zone will become a pure page_allocator. memory layout is managed by
> pgdat.
> 
> This change has benefit for memory-hotplug and maybe other works.
> We can define a zone which is free from memory layout, like ZONE_EASYRCLM,
> ZONE_EMERGENCY(currently maneged by mempool) etc..witout inconsistency.
> 
> for_each_page_in_zone() uses zone's memory layout information, but this
> patch doesn't include fixes for it. It will be fixed by following patch.

Geez, that removes a bunch of code.  _My_ code.  I like it. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
