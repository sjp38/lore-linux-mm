Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 81E8C6B00A6
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 17:36:29 -0500 (EST)
Message-ID: <50C90690.2000700@redhat.com>
Date: Wed, 12 Dec 2012 17:34:56 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 8/8] mm: reduce rmap overhead for ex-KSM page copies created
 on swap faults
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org> <1355348620-9382-9-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-9-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> When ex-KSM pages are faulted from swap cache, the fault handler is
> not capable of re-establishing anon_vma-spanning KSM pages.  In this
> case, a copy of the page is created instead, just like during a COW
> break.
>
> These freshly made copies are known to be exclusive to the faulting
> VMA and there is no reason to go look for this page in parent and
> sibling processes during rmap operations.
>
> Use page_add_new_anon_rmap() for these copies.  This also puts them on
> the proper LRU lists and marks them SwapBacked, so we can get rid of
> doing this ad-hoc in the KSM copy code.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
