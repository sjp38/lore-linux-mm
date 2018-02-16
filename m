Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 39C976B000A
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:03:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id l7so1194659wmh.4
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:03:58 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id n47si13330982wrn.397.2018.02.16.09.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Feb 2018 09:03:56 -0800 (PST)
Date: Fri, 16 Feb 2018 09:03:55 -0800
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 1/2] Protect larger order pages from breaking up
Message-ID: <20180216170354.vpbuugzqsrrfc4js@two.firstfloor.org>
References: <20180216160110.641666320@linux.com>
 <20180216160121.519788537@linux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180216160121.519788537@linux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Mel Gorman <mel@skynet.ie>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, akpm@linux-foundation.org, Thomas Schoebel-Theuer <tst@schoebel-theuer.de>, andi@firstfloor.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Guy Shattah <sguy@mellanox.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, David Nellans <dnellans@nvidia.com>, Laura Abbott <labbott@redhat.com>, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave.hansen@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>

> First performance tests in a virtual enviroment show
> a hackbench improvement by 6% just by increasing
> the page size used by the page allocator to order 3.

So why is hackbench improving? Is that just for kernel stacks?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
