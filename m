Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7407C6B00C2
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:49:58 -0400 (EDT)
Received: by ywh42 with SMTP id 42so2539901ywh.30
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 06:50:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1251449067-3109-3-git-send-email-mel@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
	 <1251449067-3109-3-git-send-email-mel@csn.ul.ie>
Date: Fri, 28 Aug 2009 22:49:59 +0900
Message-ID: <28c262360908280649j2920445ekf5625eb0e86752a4@mail.gmail.com>
Subject: Re: [PATCH 2/2] page-allocator: Maintain rolling count of pages to
	free from the PCP
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 28, 2009 at 5:44 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> When round-robin freeing pages from the PCP lists, empty lists may be
> encountered. In the event one of the lists has more pages than another,
> there may be numerous checks for list_empty() which is undesirable. This
> patch maintains a count of pages to free which is incremented when empty
> lists are encountered. The intention is that more pages will then be freed
> from fuller lists than the empty ones reducing the number of empty list
> checks in the free path.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I like this idea. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
