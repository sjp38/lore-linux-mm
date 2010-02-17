Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1A1036B0078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 10:46:28 -0500 (EST)
Message-ID: <4B7C0F2A.3020905@redhat.com>
Date: Wed, 17 Feb 2010 10:45:46 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/12] Memory compaction core
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-6-git-send-email-mel@csn.ul.ie> <20100216170014.7309.A69D9226@jp.fujitsu.com> <20100217132952.GA1663@csn.ul.ie>
In-Reply-To: <20100217132952.GA1663@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/17/2010 08:29 AM, Mel Gorman wrote:

> Fix concerns from Kosaki Motohiro (merge with compaction core)
>
> o Fewer pages are isolated. Hence, cc->migrate_pfn in
>    isolate_migratepages() is updated slightly differently and the debug
>    checks change
> o LRU lists are no longer rotated
> o NR_ISOLATED_* is updated
> o del_page_from_lru_list() is used instead list_move when isolated so
>    that the counters get updated correctly.
> o Pages that fail to migrate are put back on the LRU promptly to avoid
>    being isolated for too long.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

Consider this an ack to your patch 5/12 with these fixes.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
