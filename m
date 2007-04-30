Date: Mon, 30 Apr 2007 16:59:30 -0700
From: Bill Irwin <bill.irwin@oracle.com>
Subject: Re: 2.6.22 -mm merge plans
Message-ID: <20070430235930.GK26598@holomorphy.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070430162007.ad46e153.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 30, 2007 at 04:20:07PM -0700, Andrew Morton wrote:
>  proper-prototype-for-hugetlb_get_unmapped_area.patch
...
>  convert-hugetlbfs-to-use-vm_ops-fault.patch
...
>  get_unmapped_area-handles-map_fixed-in-hugetlbfs.patch
...
>  get_unmapped_area-doesnt-need-hugetlbfs-hacks-anymore.patch
...
> Will merge.

I've gone over these again and all are still good. The same holds for
the get_unmapped_area() series in general where I've reviewed it for
hugetlb relevance.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
