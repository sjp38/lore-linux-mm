Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 37D0D6B00D1
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 05:50:20 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1237752784-1989-3-git-send-email-hannes@cmpxchg.org>
References: <1237752784-1989-3-git-send-email-hannes@cmpxchg.org> <20090321102044.GA3427@cmpxchg.org>
Subject: Re: [patch 3/3] mm: keep pages from unevictable mappings off the LRU lists
Date: Mon, 23 Mar 2009 10:53:27 +0000
Message-ID: <12135.1237805607@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dhowells@redhat.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.com>, MinChan Kim <minchan.kim@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:

> -		if (page_is_file_cache(page))
> +		if (mapping_unevictable(mapping))
> +			add_page_to_unevictable_list(page);
> +		else if (page_is_file_cache(page))

It would be nice to avoid adding an extra test and branch in here.  This
function is used a lot, and quite often we know the answer to the first test
before we even get here.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
