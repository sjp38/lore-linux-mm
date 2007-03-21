Date: Wed, 21 Mar 2007 15:55:54 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 0/7] [RFC] hugetlb: pagetable_operations API (V2)
In-Reply-To: <20070319200502.17168.17175.stgit@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0703211549220.32077@blonde.wat.veritas.com>
References: <20070319200502.17168.17175.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, William Lee Irwin III <wli@holomorphy.com>, Christoph Hellwig <hch@infradead.org>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Mar 2007, Adam Litke wrote:
> Andrew, given the favorable review of these patches the last time around, would
> you consider them for the -mm tree?  Does anyone else have any objections?

I quite fail to understand the enthusiasm for these patches.  All they
do is make the already ugly interfaces to hugetlb more obscure than at
present, and open the door to even uglier stuff later.  Don't you need
to wait for at least one other user of these interfaces to emerge,
to get a better idea of whether they're appropriate?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
