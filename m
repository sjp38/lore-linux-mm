Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2FCkxOv022407
	for <linux-mm@kvack.org>; Thu, 15 Mar 2007 08:46:59 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2FCkxac081904
	for <linux-mm@kvack.org>; Thu, 15 Mar 2007 08:46:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2FCkwri031844
	for <linux-mm@kvack.org>; Thu, 15 Mar 2007 08:46:59 -0400
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <Pine.GSO.4.64.0703150045550.18191@cpu102.cs.uwaterloo.ca>
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca>
	 <Pine.GSO.4.64.0703150045550.18191@cpu102.cs.uwaterloo.ca>
Content-Type: text/plain
Date: Thu, 15 Mar 2007 07:46:56 -0500
Message-Id: <1173962816.14380.8.camel@kleikamp.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ashif Harji <asharji@cs.uwaterloo.ca>
Cc: Xiaoning Ding <dingxn@cse.ohio-state.edu>, Andreas Mohr <andi@rhlx01.fht-esslingen.de>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-03-15 at 01:22 -0400, Ashif Harji wrote:

> I would tend to agree with David that:  "Any application doing many 
> tiny-sized reads isn't exactly asking for great performance."  As well, 
> applications concerned with performance and caching problems can read in a 
> file in PAGE_SIZE chunks.  I still think the simple fix of removing the 
> condition is the best approach, but I'm certainly open to alternatives.

A possible alternative might be to store the offset within the page in
the readahead state, and call mark_page_accessed() when the read offset
is less than or equal to the previous offset.

-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
