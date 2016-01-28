Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 301246B0254
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 18:42:56 -0500 (EST)
Received: by mail-oi0-f43.google.com with SMTP id r14so37310138oie.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:42:56 -0800 (PST)
Received: from alln-iport-6.cisco.com (alln-iport-6.cisco.com. [173.37.142.93])
        by mx.google.com with ESMTPS id j145si1507310oih.64.2016.01.28.15.42.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 15:42:55 -0800 (PST)
From: Daniel Walker <danielwa@cisco.com>
Subject: computing drop-able caches
Message-ID: <56AAA77D.7090000@cisco.com>
Date: Thu, 28 Jan 2016 15:42:53 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

Hi,

My colleague Khalid and I are working on a patch which will provide a 
/proc file to output the size of the drop-able page cache.
One way to implement this is to use the current drop_caches /proc 
routine, but instead of actually droping the caches just add
up the amount.

Here's a quote Khalid,

"Currently there is no way to figure out the droppable pagecache size
from the meminfo output. The MemFree size can shrink during normal
system operation, when some of the memory pages get cached and is
reflected in "Cached" field. Similarly for file operations some of
the buffer memory gets cached and it is reflected in "Buffers" field.
The kernel automatically reclaims all this cached & buffered memory,
when it is needed elsewhere on the system. The only way to manually
reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. "

So my impression is that the drop-able cache is spread over two fields 
in meminfo.

Alright, the question is does this info live someplace else that we 
don't know about? Or someplace in the kernel where it could be
added to meminfo trivially ?

The point of the whole exercise is to get a better idea of free memory 
for our employer. Does it make sense to do this for computing free memory?

Any comments welcome..

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
