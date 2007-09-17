Message-ID: <46EEC24C.7000703@cray.com>
Date: Mon, 17 Sep 2007 13:07:08 -0500
From: Andrew Hastings <abh@cray.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] [hugetlb] Dynamic huge page pool resizing
References: <20070917163935.32557.50840.stgit@kernel>
In-Reply-To: <20070917163935.32557.50840.stgit@kernel>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Adam Litke wrote:
> The obvious answer is to let the hugetlb pool grow and shrink in response to
> the runtime demand for huge pages.  The work Mel Gorman has been doing to
> establish a memory zone for movable memory allocations makes dynamically
> resizing the hugetlb pool reliable within the limits of that zone.  This patch
> series implements dynamic pool resizing for private and shared mappings while
> being careful to maintain existing semantics.  Please reply with your comments
> and feedback; even just to say whether it would be a useful feature to you.

Thanks, this will be extremely useful for our customers' workloads.

-Andrew Hastings
  Cray Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
