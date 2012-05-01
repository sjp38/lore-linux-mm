Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 675CD6B004D
	for <linux-mm@kvack.org>; Tue,  1 May 2012 17:06:34 -0400 (EDT)
Message-ID: <4FA0504D.60802@redhat.com>
Date: Tue, 01 May 2012 17:06:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/5] mm: readahead: move radix tree hole searching here
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org> <1335861713-4573-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1335861713-4573-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/01/2012 04:41 AM, Johannes Weiner wrote:
> The readahead code searches the page cache for non-present pages, or
> holes, to get a picture of the area surrounding a fault e.g.
>
> For this it sufficed to rely on the radix tree definition of holes,
> which is "empty tree slot".  This is about to change, though, because
> shadow page descriptors will be stored in the page cache when the real
> pages get evicted from memory.
>
> Fortunately, nobody outside the readahead code uses these functions
> and they have no internal knowledge of the radix tree structures, so
> just move them over to mm/readahead.c where they can later be adapted
> to handle the new definition of "page cache hole".
>
> Signed-off-by: Johannes Weiner<hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
