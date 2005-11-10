Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAANNSpp025756
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 18:23:28 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAANNMhE057206
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 16:23:22 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAANNR0r027079
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 16:23:27 -0700
Subject: [RFC] sys_punchhole()
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Thu, 10 Nov 2005 15:23:14 -0800
Message-Id: <1131664994.25354.36.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, andrea@suse.de, hugh@veritas.com
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Andrew,

We discussed this in madvise(REMOVE) thread - to add support 
for sys_punchhole(fd, offset, len) to complete the functionality
(in the future).

http://marc.theaimsgroup.com/?l=linux-mm&m=113036713810002&w=2

What I am wondering is, should I invest time now to do it ?
Or wait till need arises ? 

My thought line is, I would add a generic_zeroblocks_range() 
function which would zero out the given range of pages and 
flush to disk.  Use this as a default operation, if the 
filesystems doesn't provide a specific function to free up
the blocks. Would this work ?

Suggestions ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
