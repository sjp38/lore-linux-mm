Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id C0ABE6B0253
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 12:05:37 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so113055862wib.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 09:05:37 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id lt3si34286776wjb.33.2015.08.18.09.05.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 09:05:36 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so99269216wic.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 09:05:32 -0700 (PDT)
Date: Tue, 18 Aug 2015 18:05:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv2 3/4] mm: pack compound_dtor and compound_order into one
 word in struct page
Message-ID: <20150818160530.GM5033@dhcp22.suse.cz>
References: <1439824145-25397-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439824145-25397-4-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439824145-25397-4-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 17-08-15 18:09:04, Kirill A. Shutemov wrote:
[...]
> +/* Keep the enum in sync with compound_page_dtors array in mm/page_alloc.c */
> +enum {
> +	NULL_COMPOUND_DTOR,
> +	COMPOUND_PAGE_DTOR,
> +	HUGETLB_PAGE_DTOR,
> +	NR_COMPOUND_DTORS,
> +};
[...]
> +static void free_compound_page(struct page *page);
> +compound_page_dtor * const compound_page_dtors[] = {
> +	NULL,
> +	free_compound_page,
> +	free_huge_page,
> +};
> +

Both need ifdef CONFIG_HUGETLB_PAGE as my compile test batter just found
out.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
