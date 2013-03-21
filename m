Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 04BFC6B0036
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 13:18:49 -0400 (EDT)
Message-ID: <514B4142.7040000@sr71.net>
Date: Thu, 21 Mar 2013 10:20:02 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 10/30] thp, mm: locking tail page is a bug
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-11-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> index 0ff3403..38fdc92 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -669,6 +669,7 @@ void __lock_page(struct page *page)
>  {
>  	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
>  
> +	VM_BUG_ON(PageTail(page));
>  	__wait_on_bit_lock(page_waitqueue(page), &wait, sleep_on_page,
>  							TASK_UNINTERRUPTIBLE);
>  }

Could we get a bit more of a description here in a comment or in the
patch summary about this?  It makes some sense to me that code shouldn't
be mucking with the tail pages, but I'm curious what your logic is here,
too.  I'm sure you've thought about it a lot more than I have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
