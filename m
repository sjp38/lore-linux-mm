Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7BAE36B003C
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 09:33:33 -0400 (EDT)
Received: by mail-bk0-f43.google.com with SMTP id v15so185463bkz.2
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 06:33:32 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id x9si2460827bkn.255.2014.03.14.06.33.31
        for <linux-mm@kvack.org>;
        Fri, 14 Mar 2014 06:33:31 -0700 (PDT)
Date: Fri, 14 Mar 2014 15:33:11 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 3/6] mm: support madvise(MADV_FREE)
Message-ID: <20140314133311.GA6316@node.dhcp.inet.fi>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
 <1394779070-8545-4-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394779070-8545-4-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>

On Fri, Mar 14, 2014 at 03:37:47PM +0900, Minchan Kim wrote:
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c1b7414c7bef..9b048cabce27 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -933,10 +933,16 @@ void page_address_init(void);
>   * Please note that, confusingly, "page_mapping" refers to the inode
>   * address_space which maps the page from disk; whereas "page_mapped"
>   * refers to user virtual address space into which the page is mapped.
> + *
> + * PAGE_MAPPING_LZFREE bit is set along with PAGE_MAPPING_ANON bit
> + * and then page->mapping points to an anon_vma. This flag is used
> + * for lazy freeing the page instead of swap.
>   */
>  #define PAGE_MAPPING_ANON	1
>  #define PAGE_MAPPING_KSM	2
> -#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM)
> +#define PAGE_MAPPING_LZFREE	4
> +#define PAGE_MAPPING_FLAGS	(PAGE_MAPPING_ANON | PAGE_MAPPING_KSM | \
> +				 PAGE_MAPPING_LZFREE)

Is it safe to use third bit in pointer everywhere?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
