Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 810486B005C
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 11:01:27 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id p127so1700523oic.21
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:01:27 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id q67si11045591itg.126.2018.02.16.08.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 08:01:24 -0800 (PST)
Message-Id: <20180216160110.641666320@linux.com>
Date: Fri, 16 Feb 2018 10:01:10 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [RFC 0/2] Larger Order Protection V1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

We have discussed for years ways to create more reliable ways to allocate large contiguous
memory segments and to avoid fragmentation. This is an ad hoc scheme based on reservation
of higher order pages in the page allocator. It is fully transparent and integrated
into the page allocator.

This approach goes back to the meeting on contiguous memory at the Plumbers conference
in 2017 and the effort by Guy and Mike Kravetz to establish and API to map contiguous
memory segments into user space. Reservations will allow the contiguous memory allocations
to work even after the system has run for a considerable time.

Contiguous memory is also important for general system performance. F.e. slab
allocators can be made to use large frames in order to optimize performance.
See patch 1.

Other use cases are jumbo frames or device driver specific allocations.

For more on this see Mike Kravetz patches in particular 

Mike Kravetz MMAP CONTIG flag support at

https://lkml.org/lkml/2017/10/3/992


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
