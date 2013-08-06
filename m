Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id DB7FD6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 16:24:07 -0400 (EDT)
Message-ID: <52015B54.5010605@sr71.net>
Date: Tue, 06 Aug 2013 13:23:48 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 19/23] truncate: support huge pages
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com> <1375582645-29274-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-20-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 08/03/2013 07:17 PM, Kirill A. Shutemov wrote:
> +			if (PageTransTailCache(page)) {
> +				/* part of already handled huge page */
> +				if (!page->mapping)
> +					continue;
> +				/* the range starts in middle of huge page */
> +				partial_thp_start = true;
> +				start = index & ~HPAGE_CACHE_INDEX_MASK;
> +				continue;
> +			}
> +			/* the range ends on huge page */
> +			if (PageTransHugeCache(page) &&
> +				index == (end & ~HPAGE_CACHE_INDEX_MASK)) {
> +				partial_thp_end = true;
> +				end = index;
> +				break;
> +			}

Still reading through the code, but that "index ==" line's indentation
is screwed up.  It makes it look like "index == " is a line of code
instead of part of the if() condition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
