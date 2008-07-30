Date: Wed, 30 Jul 2008 13:07:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-Id: <20080730130709.eb541475.akpm@linux-foundation.org>
In-Reply-To: <20080730193010.GB14138@csn.ul.ie>
References: <cover.1216928613.git.ebmunson@us.ibm.com>
	<20080730014308.2a447e71.akpm@linux-foundation.org>
	<20080730172317.GA14138@csn.ul.ie>
	<20080730103407.b110afc2.akpm@linux-foundation.org>
	<20080730193010.GB14138@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: ebmunson@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jul 2008 20:30:10 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> With Erics patch and libhugetlbfs, we can automatically back text/data[1],
> malloc[2] and stacks without source modification. Fairly soon, libhugetlbfs
> will also be able to override shmget() to add SHM_HUGETLB. That should cover
> a lot of the memory-intensive apps without source modification.

The weak link in all of this still might be the need to reserve
hugepages and the unreliability of dynamically allocating them.

The dynamic allocation should be better nowadays, but I've lost track
of how reliable it really is.  What's our status there?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
