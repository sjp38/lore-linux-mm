Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2KNoS4I029897
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 19:50:28 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l2KNoS09069398
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 17:50:28 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2KNoRTj012971
	for <linux-mm@kvack.org>; Tue, 20 Mar 2007 17:50:28 -0600
Subject: Re: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API (V2)
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <20070319200502.17168.17175.stgit@localhost.localdomain>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 20 Mar 2007 16:50:13 -0700
Message-Id: <1174434613.26166.182.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-03-19 at 13:05 -0700, Adam Litke wrote:
> For the common case (vma->pagetable_ops == NULL), we do almost the
> same thing as the current code: load and test.  The third instruction
> is different in that we jump for the common case instead of jumping in
> the hugetlb case.  I don't think this is a big deal though.  If it is,
> would an unlikely() macro fix it? 

I wouldn't worry about micro-optimizing it at that level.  The CPU does
enough stuff under the covers that I wouldn't worry about it at all.

I wonder if the real differential impact (if any) is likely to come from
the pagetable_ops cacheline being hot or cold, since it is in a
different place in the structure than the flags.  But, from a quick
glance I see a few vm_ops references preceding pagetable_ops references,
so the pagetable_ops cacheline might already be hot most of the time.  

BTW, are there any other possible users for these things other than
large pages?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
