Date: Thu, 12 Apr 2007 15:32:01 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 12/12] get_unmapped_area doesn't need hugetlbfs hacks anymore
Message-ID: <20070412223201.GM2986@holomorphy.com>
References: <1176344427.242579.337989891532.qpush@grosgo> <20070412022035.4BD9CDDF32@ozlabs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070412022035.4BD9CDDF32@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 12, 2007 at 12:20:33PM +1000, Benjamin Herrenschmidt wrote:
> Remove the hugetlbfs specific hacks in toplevel get_unmapped_area() now
> that all archs and hugetlbfs itself do the right thing for both cases.
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>  mm/mmap.c |   16 ----------------
>  1 file changed, 16 deletions(-)

Acked-by: William Irwin <bill.irwin@oracle.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
