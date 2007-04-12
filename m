Date: Thu, 12 Apr 2007 15:29:45 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 6/12] get_unmapped_area handles MAP_FIXED on ia64
Message-ID: <20070412222945.GJ2986@holomorphy.com>
References: <1176344427.242579.337989891532.qpush@grosgo> <20070412022032.2CDA1DDF2D@ozlabs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070412022032.2CDA1DDF2D@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 12, 2007 at 12:20:30PM +1000, Benjamin Herrenschmidt wrote:
> Handle MAP_FIXED in ia64 arch_get_unmapped_area and
> hugetlb_get_unmapped_area(), just call prepare_hugepage_range
> in the later and is_hugepage_only_range() in the former.
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>  arch/ia64/kernel/sys_ia64.c |    7 +++++++
>  arch/ia64/mm/hugetlbpage.c  |    8 ++++++++
>  2 files changed, 15 insertions(+)

Acked-by: William Irwin <bill.irwin@oracle.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
