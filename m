Date: Thu, 12 Apr 2007 15:28:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 5/12] get_unmapped_area handles MAP_FIXED on i386
Message-ID: <20070412222855.GI2986@holomorphy.com>
References: <1176344427.242579.337989891532.qpush@grosgo> <20070412022031.A810EDDF2A@ozlabs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070412022031.A810EDDF2A@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 12, 2007 at 12:20:29PM +1000, Benjamin Herrenschmidt wrote:
> Handle MAP_FIXED in i386 hugetlb_get_unmapped_area(), just call
> prepare_hugepage_range.
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>  arch/i386/mm/hugetlbpage.c |    6 ++++++
>  1 file changed, 6 insertions(+)

Acked-by: William Irwin <bill.irwin@oracle.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
