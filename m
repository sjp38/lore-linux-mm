Date: Tue, 2 Oct 2007 02:41:44 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: [PATCH 0/4] [hugetlb] Dynamic huge page pool resizing V6
Message-ID: <20071002094144.GN6861@holomorphy.com>
References: <20071001151736.12825.75984.stgit@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071001151736.12825.75984.stgit@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>, Dave McCracken <dave.mccracken@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 01, 2007 at 08:17:36AM -0700, Adam Litke wrote:
> This release contains no significant changes to any of the patches.  I have
> been running regression and performance tests on a variety of machines and
> configurations.  Andrew, these patches relax restrictions related to sizing the
> hugetlb pool.  The patches have reached stability in content, function, and
> performance and I believe they are ready for wider testing.  Please consider
> for merging into -mm.  I have included performance results at the end of this
> mail.

I very much like the concept and am impressed with the testing level.
I'll ack the individual patches as I get to them.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
