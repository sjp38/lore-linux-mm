Date: Fri, 23 Mar 2007 08:09:24 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] rfc: introduce /dev/hugetlb
Message-ID: <20070323150924.GV2986@holomorphy.com>
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com> <Pine.LNX.4.64.0703231457360.4133@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0703231457360.4133@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ken Chen <kenchen@google.com>, Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Mar 2007, Ken Chen wrote:
> >-#ifdef HAVE_ARCH_HUGETLB_UNMAPPED_AREA
> >-unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long 
> >addr,
> >-		unsigned long len, unsigned long pgoff, unsigned long flags);
> >-#else
> >-static unsigned long
> >+unsigned long
> >hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
> >		unsigned long len, unsigned long pgoff, unsigned long flags)
> 
On Fri, Mar 23, 2007 at 03:03:57PM +0000, Mel Gorman wrote:
> What is going on here? Why do arches not get to specify a 
> get_unmapped_area any more?

Lack of compiletesting beyond x86-64 in all probability.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
