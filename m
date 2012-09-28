Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 47FDA6B005D
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 11:14:13 -0400 (EDT)
Message-ID: <5065BEBF.1010705@redhat.com>
Date: Fri, 28 Sep 2012 11:14:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: avoid VM_BUG_ON page_count(page) false positives
 in __collapse_huge_page_copy
References: <1348835731-27474-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1348835731-27474-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>

On 09/28/2012 08:35 AM, Andrea Arcangeli wrote:
> Speculative cache pagecache lookups can elevate the refcount from
> under us, so avoid the false positive. If the refcount is < 2 we'll be
> notified by a VM_BUG_ON in put_page_testzero as there are two
> put_page(src_page) in a row before returning from this function.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
