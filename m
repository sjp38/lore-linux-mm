Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 9BA156B005A
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 20:46:30 -0400 (EDT)
Date: Mon, 23 Jul 2012 09:46:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/3] zsmalloc: add page table mapping method
Message-ID: <20120723004646.GD4037@bbox>
References: <1342630556-28686-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1342630556-28686-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20120723002655.GC4037@bbox>
 <500C9BE4.70108@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <500C9BE4.70108@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Hi Seth,

On Sun, Jul 22, 2012 at 07:33:40PM -0500, Seth Jennings wrote:
> On 07/22/2012 07:26 PM, Minchan Kim wrote:
> > On Wed, Jul 18, 2012 at 11:55:56AM -0500, Seth Jennings wrote:
> >> This patchset provides page mapping via the page table.
> >> On some archs, most notably ARM, this method has been
> >> demonstrated to be faster than copying.
> >>
> >> The logic controlling the method selection (copy vs page table)
> >> is controlled by the definition of USE_PGTABLE_MAPPING which
> >> is/can be defined for any arch that performs better with page
> >> table mapping.
> >>
> >> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> >> ---
> >>  drivers/staging/zsmalloc/zsmalloc-main.c |  182 ++++++++++++++++++++++--------
> >>  drivers/staging/zsmalloc/zsmalloc_int.h  |    6 -
> >>  2 files changed, 134 insertions(+), 54 deletions(-)
> >>
> >> diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> >> index b86133f..defe350 100644
> >> --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> >> +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> >> @@ -89,6 +89,30 @@
> >>  #define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
> >>  #define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
> >>  
> >> +/*
> >> + * By default, zsmalloc uses a copy-based object mapping method to access
> >> + * allocations that span two pages. However, if a particular architecture
> >> + * 1) Implements local_flush_tlb_kernel_range() and 2) Performs VM mapping
> >> + * faster than copying, then it should be added here so that
> > 
> > How about adding your benchmark url?
> > 
> >> + * USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use page table
> >> + * mapping rather than copying
> >> + * for object mapping.
> > 
> > unnecessary new line.
> 
> Since these aren't functional issues with the code, if I
> _promise_ to send a follow-up patch to address these, can I
> get your Ack?

Sure!

Thanks for your effort!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
