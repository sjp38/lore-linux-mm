From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: [PATCH 0/4] [hugetlb] Dynamic huge page pool resizing
Date: Mon, 17 Sep 2007 12:37:00 -0500
References: <20070917163935.32557.50840.stgit@kernel>
In-Reply-To: <20070917163935.32557.50840.stgit@kernel>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200709171237.00847.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Monday 17 September 2007, Adam Litke wrote:
> In most real-world scenarios, configuring the size of the hugetlb pool
> correctly is a difficult task. A If too few pages are allocated to the pool,
> applications using MAP_SHARED may fail to mmap() a hugepage region and
> applications using MAP_PRIVATE may receive SIGBUS. A Isolating too much
> memory in the hugetlb pool means it is not available for other uses,
> especially those programs not using huge pages.
>
> The obvious answer is to let the hugetlb pool grow and shrink in response
> to the runtime demand for huge pages. A The work Mel Gorman has been doing
> to establish a memory zone for movable memory allocations makes dynamically
> resizing the hugetlb pool reliable within the limits of that zone. A This
> patch series implements dynamic pool resizing for private and shared
> mappings while being careful to maintain existing semantics. A Please reply
> with your comments and feedback; even just to say whether it would be a
> useful feature to you. Thanks.

Now that we have Mel's mobility patches to make it feasible to dynamically 
allocate huge pages, I'd say it's definitely time to get this patch in.  
Users will really appreciate not having to preallocate huge pages for all 
possible workloads.

Dave

Acked-by: Dave McCracken <dave.mccracken@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
