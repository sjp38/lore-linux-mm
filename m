Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k16JRxfK017015
	for <linux-mm@kvack.org>; Mon, 6 Feb 2006 14:27:59 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k16JRwWC180544
	for <linux-mm@kvack.org>; Mon, 6 Feb 2006 14:27:58 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k16JRvCu024976
	for <linux-mm@kvack.org>; Mon, 6 Feb 2006 14:27:57 -0500
Subject: Re: [RFC] pearing off zone from physical memory layout [0/10]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <43E307DB.3000903@jp.fujitsu.com>
References: <43E307DB.3000903@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 06 Feb 2006 11:27:43 -0800
Message-Id: <1139254063.6189.97.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-02-03 at 16:35 +0900, KAMEZAWA Hiroyuki wrote:
> This series of patches remove members from zone, which depends on physical
> memory layout, zone_start_pfn, spanned_pages, zone_mem_map against 2.6.16-rc1.
> 
> By this, zone's meaning will be changed from "a range of memory to be used
> in a same manner" to "a group of memory to be used in a same manner".

This looks like pretty good stuff.  I especially like that it gets rid
of that seqlock that I had to add for memory hotplug.  My only concern
would be in the increased page_to_pfn() overhead.  Any data on that?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
