Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9A5F26B0111
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 12:01:40 -0400 (EDT)
Message-ID: <4A6737D7.5070909@redhat.com>
Date: Wed, 22 Jul 2009 12:01:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/4] mm: introduce page_lru_type()
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1248166594-8859-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
> Instead of abusing page_is_file_cache() for LRU list index arithmetic,
> add another helper with a more appropriate name and convert the
> non-boolean users of page_is_file_cache() accordingly.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
