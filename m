Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DA2C36B00CD
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 05:37:51 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1237752784-1989-2-git-send-email-hannes@cmpxchg.org>
References: <1237752784-1989-2-git-send-email-hannes@cmpxchg.org> <20090321102044.GA3427@cmpxchg.org>
Subject: Re: [patch 2/3] ramfs-nommu: use generic lru cache
Date: Mon, 23 Mar 2009 10:40:42 +0000
Message-ID: <11989.1237804842@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:

> Instead of open-coding the lru-list-add pagevec batching when
> expanding a file mapping from zero, defer to the appropriate page
> cache function that also takes care of adding the page to the lru
> list.
> 
> This is cleaner, saves code and reduces the stack footprint by 16
> words worth of pagevec.

Acked-by: David Howells <dhowells@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
