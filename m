Message-ID: <4890C3A5.8050700@linux-foundation.org>
Date: Wed, 30 Jul 2008 14:40:21 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
References: <cover.1216928613.git.ebmunson@us.ibm.com> <20080730014308.2a447e71.akpm@linux-foundation.org> <20080730172317.GA14138@csn.ul.ie> <20080730103407.b110afc2.akpm@linux-foundation.org> <20080730193010.GB14138@csn.ul.ie>
In-Reply-To: <20080730193010.GB14138@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Eric Munson <ebmunson@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net, Andrew Hastings <abh@cray.com>
List-ID: <linux-mm.kvack.org>

Mel Gorman wrote:

> With Erics patch and libhugetlbfs, we can automatically back text/data[1],
> malloc[2] and stacks without source modification. Fairly soon, libhugetlbfs
> will also be able to override shmget() to add SHM_HUGETLB. That should cover
> a lot of the memory-intensive apps without source modification.

So we are quite far down the road to having a VM that supports 2 page sizes 4k and 2M?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
