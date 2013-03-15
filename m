Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 5D52A6B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 02:15:12 -0400 (EDT)
Received: by mail-ob0-f181.google.com with SMTP id ni5so2837435obc.40
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 23:15:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363283435-7666-17-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-17-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Mar 2013 14:15:11 +0800
Message-ID: <CAJd=RBCxNgjUUSbbTnVymC7+O51LKDuKTyTkEGYwuWYB9_oUmw@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 16/30] thp: handle file pages in split_huge_page()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> -int split_huge_page(struct page *page)
> +static int split_anon_huge_page(struct page *page)
>  {
>         struct anon_vma *anon_vma;
>         int ret = 1;
>
> -       BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
> -       BUG_ON(!PageAnon(page));
> -
deleted, why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
