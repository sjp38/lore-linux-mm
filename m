Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 1DDC06B0027
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 23:11:33 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id i10so3009352oag.0
        for <linux-mm@kvack.org>; Thu, 14 Mar 2013 20:11:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363283435-7666-15-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1363283435-7666-15-git-send-email-kirill.shutemov@linux.intel.com>
Date: Fri, 15 Mar 2013 11:11:32 +0800
Message-ID: <CAJd=RBA-CRVu2is9=9E1Y0=HFRHs1TXvFvm2wF7gT+=ujQ+8tg@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 14/30] thp, mm: naive support of thp in generic
 read/write routines
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> +               if (PageTransTail(page)) {
> +                       page_cache_release(page);
> +                       page = find_get_page(mapping,
> +                                       index & ~HPAGE_CACHE_INDEX_MASK);
check page is valid, please.

> +                       if (!PageTransHuge(page)) {
> +                               page_cache_release(page);
> +                               goto find_page;
> +                       }
> +               }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
