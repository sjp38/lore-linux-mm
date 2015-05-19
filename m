Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 610E66B007B
	for <linux-mm@kvack.org>; Tue, 19 May 2015 00:00:48 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so101317578wic.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 21:00:48 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id w13si16486188wjq.111.2015.05.18.21.00.46
        for <linux-mm@kvack.org>;
        Mon, 18 May 2015 21:00:47 -0700 (PDT)
Date: Tue, 19 May 2015 07:00:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 20/28] mm: differentiate page_mapped() from
 page_mapcount() for compound pages
Message-ID: <20150519040032.GB5795@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-21-git-send-email-kirill.shutemov@linux.intel.com>
 <555A06B4.2000706@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <555A06B4.2000706@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 18, 2015 at 05:35:16PM +0200, Vlastimil Babka wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> >Let's define page_mapped() to be true for compound pages if any
> >sub-pages of the compound page is mapped (with PMD or PTE).
> >
> >On other hand page_mapcount() return mapcount for this particular small
> >page.
> >
> >This will make cases like page_get_anon_vma() behave correctly once we
> >allow huge pages to be mapped with PTE.
> >
> >Most users outside core-mm should use page_mapcount() instead of
> >page_mapped().
> 
> Does "should" mean that they do that now, or just that you would like them
> to?

I would like them to.

> Should there be a warning before the function then?

Ok.

> >Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> >Tested-by: Sasha Levin <sasha.levin@oracle.com>
> 
> >--- a/include/linux/mm.h
> >+++ b/include/linux/mm.h
> >@@ -909,7 +909,16 @@ static inline pgoff_t page_file_index(struct page *page)
> 
> (not shown in the diff)
> 
>  * Return true if this page is mapped into pagetables.
> >   */
> 
> Expand the comment? Especially if you put compound_head() there.

Ok.

> >  static inline int page_mapped(struct page *page)
> 
> Convert to proper bool while at it?

Ok.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
