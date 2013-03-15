Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id AAADF6B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 22:25:06 -0400 (EDT)
Received: by mail-oa0-f47.google.com with SMTP id o17so2911743oag.20
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 19:25:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363283435-7666-10-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-10-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Mar 2013 10:25:05 +0800
Message-ID: <CAJd=RBDWGNUvjPBiOmYDOfwbf8ZvyoMDdZn8uhcN0xTNbgKYfA@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 09/30] thp, mm: rewrite delete_from_page_cache() to
 support huge pages
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> +       if (PageTransHuge(page)) {
> +               int i;
> +
> +               for (i = 0; i < HPAGE_CACHE_NR; i++)
> +                       radix_tree_delete(&mapping->page_tree, page->index + i);

Move the below page_cache_release for tail page here, please.

> +               nr = HPAGE_CACHE_NR;
[...]
> +       if (PageTransHuge(page))
> +               for (i = 1; i < HPAGE_CACHE_NR; i++)
> +                       page_cache_release(page + i);
>         page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
