Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5816860071F
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 10:27:07 -0400 (EDT)
Received: by iwn35 with SMTP id 35so187383iwn.14
        for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:27:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1277811288-5195-2-git-send-email-mel@csn.ul.ie>
References: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
	<1277811288-5195-2-git-send-email-mel@csn.ul.ie>
Date: Tue, 29 Jun 2010 23:27:05 +0900
Message-ID: <AANLkTilwzGf2rikXYAe4Evl41lqjk8voVSG4ICfAgUI1@mail.gmail.com>
Subject: Re: [PATCH 01/14] vmscan: Fix mapping use after free
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 29, 2010 at 8:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> From: Nick Piggin <npiggin@suse.de>
>
> Use lock_page_nosync in handle_write_error as after writepage we have no
> reference to the mapping when taking the page lock.
>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Trivial.
Please modify description of the function if you have a next turn.
"run sleeping lock_page()" -> "run sleeping lock_page_nosync"


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
