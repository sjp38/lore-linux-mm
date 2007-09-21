Message-ID: <46F353C1.6030700@argo.co.il>
Date: Fri, 21 Sep 2007 07:16:49 +0200
From: Avi Kivity <avi@argo.co.il>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] [hugetlb] Dynamic huge page pool resizing
References: <20070917163935.32557.50840.stgit@kernel>
In-Reply-To: <20070917163935.32557.50840.stgit@kernel>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
> *** Series updated to remove locked_vm accounting
> The upper bound on pool growth is governed by per-filesystem quotas which
> maintains the global nature of huge page usage limits.  Per process accounting
> of hugepages as locked memory has been pulled out of this patch series as it is
> logically separate, and will be pushed separately.
> ***
>
> In most real-world scenarios, configuring the size of the hugetlb pool
> correctly is a difficult task.  If too few pages are allocated to the pool,
> applications using MAP_SHARED may fail to mmap() a hugepage region and
> applications using MAP_PRIVATE may receive SIGBUS.  Isolating too much memory
> in the hugetlb pool means it is not available for other uses, especially those
> programs not using huge pages.
>
> The obvious answer is to let the hugetlb pool grow and shrink in response to
> the runtime demand for huge pages.  The work Mel Gorman has been doing to
> establish a memory zone for movable memory allocations makes dynamically
> resizing the hugetlb pool reliable within the limits of that zone.  This patch
> series implements dynamic pool resizing for private and shared mappings while
> being careful to maintain existing semantics.  Please reply with your comments
> and feedback; even just to say whether it would be a useful feature to you.
> Thanks.
>
>   

kvm with newer hardware (that supports nested paging) stands to benefit 
greatly from this. backing guest memory with huge pages significantly 
decreases tlb miss costs, and allows using huge tlb entries for guest 
kernel mappings.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
