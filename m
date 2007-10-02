Date: Tue, 2 Oct 2007 03:03:15 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [PATCH 1/4] hugetlb: Move update_and_free_page
Message-ID: <20071002100315.GO6861@holomorphy.com>
References: <20071001151736.12825.75984.stgit@kernel> <20071001151747.12825.92956.stgit@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071001151747.12825.92956.stgit@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 01, 2007 at 08:17:47AM -0700, Adam Litke wrote:
> This patch simply moves update_and_free_page() so that it can be reused
> later in this patch series.  The implementation is not changed.
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> Acked-by: Andy Whitcroft <apw@shadowen.org>
> Acked-by: Dave McCracken <dave.mccracken@oracle.com>

Okay, this one's easy enough.

Acked-by: William Irwin <bill.irwin@oracle.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
