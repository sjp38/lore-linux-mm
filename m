Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAUIv2UB027264
	for <linux-mm@kvack.org>; Wed, 30 Nov 2005 13:57:02 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAUIuSGt089894
	for <linux-mm@kvack.org>; Wed, 30 Nov 2005 11:56:30 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAUIuxp2025629
	for <linux-mm@kvack.org>; Wed, 30 Nov 2005 11:56:59 -0700
Subject: Better pagecache statistics ?
From: Badari Pulavarty <pbadari@us.ibm.com>
Content-Type: text/plain
Date: Wed, 30 Nov 2005 10:57:09 -0800
Message-Id: <1133377029.27824.90.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi,

Is there a effort/patches underway to provide better pagecache
statistics ? 

Basically, I am interested in finding detailed break out of
cached pages. ("Cached" in /proc/meminfo) 

Out of this "cached pages"

- How much is just file system cache (regular file data) ?
- How much is shared memory pages ?
- How much is mmaped() stuff ?
- How much is for text, data, bss, heap, malloc ?

What is the right way of getting this kind of data ? 
I was trying to add tags when we do add_to_page_cache()
and quickly got ugly :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
