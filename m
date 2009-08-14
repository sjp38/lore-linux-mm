Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4B1816B0055
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 02:56:48 -0400 (EDT)
Date: Fri, 14 Aug 2009 15:56:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 2/5] mm: introduce page_lru_base_type()
In-Reply-To: <1250065929-17392-2-git-send-email-hannes@cmpxchg.org>
References: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org> <1250065929-17392-2-git-send-email-hannes@cmpxchg.org>
Message-Id: <20090814144409.CBDE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> Instead of abusing page_is_file_cache() for LRU list index arithmetic,
> add another helper with a more appropriate name and convert the
> non-boolean users of page_is_file_cache() accordingly.
> 
> This new helper gives the LRU base type a page is supposed to live on,
> inactive anon or inactive file.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
