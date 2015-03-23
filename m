Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8E16B0038
	for <linux-mm@kvack.org>; Sun, 22 Mar 2015 20:12:30 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so169308012pdb.2
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:12:30 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id hd5si19068156pac.226.2015.03.22.17.12.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Mar 2015 17:12:29 -0700 (PDT)
Received: by pdbni2 with SMTP id ni2so169410330pdb.1
        for <linux-mm@kvack.org>; Sun, 22 Mar 2015 17:12:29 -0700 (PDT)
Date: Sun, 22 Mar 2015 17:12:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 02/16] page-flags: trivial cleanup for PageTrans*
 helpers
In-Reply-To: <1426784902-125149-3-git-send-email-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.LSU.2.11.1503221710550.2680@eggly.anvils>
References: <1426784902-125149-1-git-send-email-kirill.shutemov@linux.intel.com> <1426784902-125149-3-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Mar 2015, Kirill A. Shutemov wrote:

> Use TESTPAGEFLAG_FALSE() to get it a bit cleaner.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Yeah, this is okay too.

> ---
>  include/linux/page-flags.h | 18 +++---------------
>  1 file changed, 3 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 84d10b65cec6..327aabd9792e 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -511,21 +511,9 @@ static inline int PageTransTail(struct page *page)
>  }
>  
>  #else
> -
> -static inline int PageTransHuge(struct page *page)
> -{
> -	return 0;
> -}
> -
> -static inline int PageTransCompound(struct page *page)
> -{
> -	return 0;
> -}
> -
> -static inline int PageTransTail(struct page *page)
> -{
> -	return 0;
> -}
> +TESTPAGEFLAG_FALSE(TransHuge)
> +TESTPAGEFLAG_FALSE(TransCompound)
> +TESTPAGEFLAG_FALSE(TransTail)
>  #endif
>  
>  /*
> -- 
> 2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
