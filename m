Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D044C6B004D
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 15:28:55 -0500 (EST)
Message-ID: <4B82E8FF.90701@redhat.com>
Date: Mon, 22 Feb 2010 15:28:47 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/3] vmscan: drop page_mapping_inuse()
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org> <1266868150-25984-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1266868150-25984-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 02/22/2010 02:49 PM, Johannes Weiner wrote:
> page_mapping_inuse() is a historic predicate function for pages that
> are about to be reclaimed or deactivated.
>
> According to it, a page is in use when it is mapped into page tables
> OR part of swap cache OR backing an mmapped file.
>
> This function is used in combination with page_referenced(), which
> checks for young bits in ptes and the page descriptor itself for the
> PG_referenced bit.  Thus, checking for unmapped swap cache pages is
> meaningless as PG_referenced is not set for anonymous pages and
> unmapped pages do not have young ptes.  The test makes no difference.
>
> Protecting file pages that are not by themselves mapped but are part
> of a mapped file is also a historic leftover for short-lived things
> like the exec() code in libc.  However, the VM now does reference
> accounting and activation of pages at unmap time and thus the special
> treatment on reclaim is obsolete.
>
> This patch drops page_mapping_inuse() and switches the two callsites
> to use page_mapped() directly.
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
