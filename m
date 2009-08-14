Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D7EE66B006A
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 02:56:48 -0400 (EDT)
Date: Fri, 14 Aug 2009 15:56:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 3/5] mm: return boolean from page_is_file_cache()
In-Reply-To: <1250065929-17392-3-git-send-email-hannes@cmpxchg.org>
References: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org> <1250065929-17392-3-git-send-email-hannes@cmpxchg.org>
Message-Id: <20090814144443.CBE1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> page_is_file_cache() has been used for both boolean checks and LRU
> arithmetic, which was always a bit weird.
> 
> Now that page_lru_base_type() exists for LRU arithmetic, make
> page_is_file_cache() a real predicate function and adjust the
> boolean-using callsites to drop those pesky double negations.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
