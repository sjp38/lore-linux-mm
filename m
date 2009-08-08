Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0FD8E6B0055
	for <linux-mm@kvack.org>; Sat,  8 Aug 2009 01:47:09 -0400 (EDT)
Received: by gxk3 with SMTP id 3so2559850gxk.14
        for <linux-mm@kvack.org>; Fri, 07 Aug 2009 22:47:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1249666815-28784-2-git-send-email-mel@csn.ul.ie>
References: <1249666815-28784-1-git-send-email-mel@csn.ul.ie>
	 <1249666815-28784-2-git-send-email-mel@csn.ul.ie>
Date: Sat, 8 Aug 2009 14:47:13 +0900
Message-ID: <2f11576a0908072247y3d17c977i31ea3bca82058083@mail.gmail.com>
Subject: Re: [PATCH 1/6] tracing, page-allocator: Add trace events for page
	allocation and page freeing
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Larry Woodman <lwoodman@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/8/8 Mel Gorman <mel@csn.ul.ie>:
> This patch adds trace events for the allocation and freeing of pages,
> including the freeing of pagevecs. =A0Using the events, it will be known =
what
> struct page and pfns are being allocated and freed and what the call site
> was in many cases.
>
> The page alloc tracepoints be used as an indicator as to whether the work=
load
> was heavily dependant on the page allocator or not. You can make a guess =
based
> on vmstat but you can't get a per-process breakdown. Depending on the cal=
l
> path, the call_site for page allocation may be __get_free_pages() instead
> of a useful callsite. Instead of passing down a return address similar to
> slab debugging, the user should enable the stacktrace and seg-addr option=
s
> to get a proper stack trace.
>
> The pagevec free tracepoint has a different usecase. It can be used to ge=
t
> a idea of how many pages are being dumped off the LRU and whether it is
> kswapd doing the work or a process doing direct reclaim.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>

Looks good to me.
  Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
