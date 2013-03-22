Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 4164C6B0039
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 14:20:42 -0400 (EDT)
Message-ID: <514CA325.3010104@sr71.net>
Date: Fri, 22 Mar 2013 11:29:57 -0700
From: Dave <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2, RFC 18/30] thp, mm: truncate support for transparent
 huge page cache
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com> <1363283435-7666-19-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-19-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> @@ -280,6 +291,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  			if (index > end)
>  				break;
>  
> +			VM_BUG_ON(PageTransHuge(page));
>  			lock_page(page);
>  			WARN_ON(page->index != index);
>  			wait_on_page_writeback(page);

This looks to be during the second truncate pass where things are
allowed to block.  What's the logic behind it not being possible to
encounter TransHugePage()s here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
