Date: Fri, 23 Mar 2007 08:03:46 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [patch] rfc: introduce /dev/hugetlb
Message-ID: <20070323150346.GU2986@holomorphy.com>
References: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b040c32a0703230144r635d7902g2c36ecd7f412be31@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 23, 2007 at 01:44:38AM -0700, Ken Chen wrote:
> I think we have enough infrastructure currently in hugetlbfs to
> implement what Adam wants for something like a /dev/hugetlb char
> device (except we can't afford to have a zero hugetlb page since it
> will be too costly on some arch).
> I really like the idea of having something similar to /dev/zero for
> hugetlb page.  So I coded it up on top of existing hugetlbfs.  The
> core change is really small and half of the patch is really just
> moving things around.  I think this at least can partially fulfill the
> goal.
> Signed-off-by: Ken Chen <kenchen@google.com>

I like this patch a lot, though I'm not likely to get around to testing
it today. If userspace testcode is available that would be great to see
posted so I can just boot into things and run that.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
