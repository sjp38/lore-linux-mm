Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 63BCE6B0027
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 14:08:50 -0400 (EDT)
Message-ID: <514CA05D.6030302@sr71.net>
Date: Fri, 22 Mar 2013 11:18:05 -0700
From: Dave <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 16/30] thp: handle file pages in split_huge_page()
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-17-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> +static int split_anon_huge_page(struct page *page)
>  {
>  	struct anon_vma *anon_vma;
>  	int ret = 1;
>  
> -	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
> -	BUG_ON(!PageAnon(page));

Did you really mean to kill these BUG_ON()s?  They still look relevant
to me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
