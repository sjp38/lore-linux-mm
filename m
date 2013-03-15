Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 163C26B0036
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 22:34:49 -0400 (EDT)
Received: by mail-oa0-f54.google.com with SMTP id n12so2965662oag.13
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 19:34:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363283435-7666-14-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-14-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Mar 2013 10:34:47 +0800
Message-ID: <CAJd=RBCHLigJBWiBt==wjjm7HA3CYSSyS6odKy0BgoudVxN80g@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 13/30] thp, mm: implement grab_cache_huge_page_write_begin()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +struct page *grab_cache_huge_page_write_begin(struct address_space *mapping,
> +                       pgoff_t index, unsigned flags);
> +#else
> +static inline struct page *grab_cache_huge_page_write_begin(
> +               struct address_space *mapping, pgoff_t index, unsigned flags)
> +{
build bug?

> +       return NULL;
> +}
> +#endif
>
btw, how about grab_thp_write_begin?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
